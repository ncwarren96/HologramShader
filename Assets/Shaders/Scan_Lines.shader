Shader "Custom/Scan_Lines"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "black" {}
		_Color ("Color", Color) = (0.0,0.0,0.0,1.0)
		_Alpha ("White Space Alpha", Range (0, 1)) = 0.25
		_Speed ("Scan Line Speed", Float) = 1.0
		_Width ("Scan Line Width", Float) = 1.0
		_Percent ("Whitespace Percent", Range (0, 1)) = 0.5
		_Axis ("Scan Direction", Vector) = (0.0,1.0,0.0,0.0)
		_Glitch ("Glitch", Range(0, 1)) = 0.0
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

			float _Glitch;

			v2f vert (appdata v)
			{
				v2f o;
				o.worldVertex = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = v.vertexNormal;
				if(_Glitch > 0){
					if (sin(_Time.y * 3) > 0.999 && o.worldVertex.y > 0.25) {
						o.vertex.x = o.vertex.x - _Glitch;
					}
				}


				return o;
			}
			
			sampler2D _MainTex;
			float4 _Color;
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
			
			float rand(float4 co){
				  return (frac(sin(dot(co.xyzw ,float4(12.9898,78.233,43.3432,23.2321))) * 43758.5453)) * 0.5;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _Color;
				float3 axis = normalize(_Axis.xyz);
				float scalar = dot(axis, i.worldVertex.xyz);
				
				if (IsAxis(axis, i.normal) == 1) {
					col.a = _Alpha;
				} else {
					float innerSin = (scalar * 100 + (_Time.y * _Speed)) / (_Width);
					col.a = (sin(innerSin) > (_Percent * 2 - 1))? col.a: _Alpha;
				}
				
				float3 noiseCoord = (
					i.worldVertex.x,
					i.worldVertex.y,
					i.worldVertex.z
				);
				col.a = (col.a + rand(float4(noiseCoord.xyz * 1, _Time.x / 10000))) / 2;
				
				float timeFactor = 2;
				// 1 - (((_Time.y / 3 + scalar) % timeFactor) / timeFactor)
				float timeScalar = min(1, 1.5 - (((_Time.y / 3 + scalar)  % timeFactor) / timeFactor));
				
				col.r *= timeScalar;
				col.g *= timeScalar;
				col.b *= timeScalar;
				
				// Handle texture
				fixed4 textCol = tex2D(_MainTex, i.uv);
				if (textCol.a > 0) {
					float value = (textCol.r + textCol.g + textCol.b) / 3;
					col.r = (value + col.r) / 2;
					col.g = (value + col.g) / 2;
					col.b = (value + col.b) / 2;
				}

				return col;
			}
			ENDCG
		}
	}
}
