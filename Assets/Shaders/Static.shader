Shader "Custom/Static"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (0.0,0.0,0.0,1.0)
		_FresnelColor ("_Fresnel Color", Color) = (0.0,0.0,0.0,1.0)
		_Alpha ("White Space Alpha", Range (0, 1)) = 0.25
		_Speed ("Scan Line Speed", Float) = 1.0
		_Width ("Scan Line Width", Float) = 1.0
		_Percent ("Whitespace Percent", Range (0, 1)) = 0.5
		_Axis ("Scan Direction", Vector) = (0.0,1.0,0.0,0.0)
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 vertexNormal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 worldVertex : W_POSITION;
				float3 normal: NORMAL;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.worldVertex = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = v.vertexNormal;
				
				if (sin(_Time.y * 3) > 0.999 && o.worldVertex.y > 0.25) {
					o.vertex.x = o.vertex.x - 0.5;
				}

				return o;
			}
			
			sampler2D _MainTex;
			float4 _Color;
			float4 _FresnelColor;
			float _Alpha;
			float _Speed;
			float _Width;
			float _Percent;
			float4 _Axis;
			
			float IsAxis(float3 axis, float3 normal) {
				if (abs(dot(axis, normal)) >= 0.99) {
					return 1;
				}
				return 0;
			}
			
			float rand3(float3 co){
				return (frac(sin(dot(co.xyz ,float3(12.9898,78.233,43.3432))) * 43758.5453)) * 0.5;
			}
			
			float rand4(float4 co){
				return (frac(sin(dot(co.xyzw ,float4(12.9898,78.233,43.3432,23.2321))) * 43758.5453)) * 0.5;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _Color;
				float3 axis = normalize(_Axis.xyz);
				float scalar = dot(axis, i.worldVertex.xyz);
				
				float noiseScalar = 500;
				/*float4 noiseCoord = float4(i.worldVertex.xyz, _Time.x / 5000);
				noiseCoord.x = noiseCoord.x * noiseScalar;
				noiseCoord.y = floor(noiseCoord.y * noiseScalar);
				noiseCoord.z = floor(noiseCoord.z * noiseScalar);
				col.a = rand4(noiseCoord);*/
				float3 noiseCoord = float3(i.uv.xy, _Time.x / 5000);
				noiseCoord.x = floor(noiseCoord.x * noiseScalar / 5);
				noiseCoord.y = floor(noiseCoord.y * noiseScalar);
				col.a = rand3(noiseCoord);
				
				float3 posWorld = mul(unity_ObjectToWorld, i.worldVertex).xyz;
				float3 normWorld = mul(unity_ObjectToWorld, float4(i.normal, 0.0)).xyz;
				float3 camDir = normalize(posWorld - _WorldSpaceCameraPos.xyz);
				float fresnel = 1 - abs(dot(camDir, normWorld));
				
				col.r = col.r * (1 - fresnel) + _FresnelColor.r * fresnel;
				col.g = col.g * (1 - fresnel) + _FresnelColor.g * fresnel;
				col.b = col.b * (1 - fresnel) + _FresnelColor.b * fresnel;
				col.a = col.a * (1 - fresnel) + _FresnelColor.a * fresnel / 2; //(max(((fresnel / 1) + col.a / 2) / 2, 0.1));
				
				/*float timeFactor = 2;
				float timeScalar = min(1, 1.5 - (((_Time.y / 3 + scalar)  % timeFactor) / timeFactor));
				
				col.r *= timeScalar;
				col.g *= timeScalar;
				col.b *= timeScalar;*/

				return col;
			}
			ENDCG
		}
	}
}
