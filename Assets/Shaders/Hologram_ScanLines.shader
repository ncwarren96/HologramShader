Shader "Custom/HologramShader_ScanLines"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (0.0,0.0,0.0,1.0)
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
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _Color;
				float3 axis = normalize(_Axis.xyz);
				if (IsAxis(axis, i.normal) == 1) {
					col.a = _Alpha;
				} else {
					float scalar = dot(axis, i.worldVertex.xyz);
					float innerSin = (scalar * 100 + (_Time.y * _Speed)) / (_Width);
					col.a = (sin(innerSin) > (_Percent * 2 - 1))? col.a: _Alpha;
				}
					
				//col.a = abs(noise(i.vertex));

				return col;
			}
			ENDCG
		}
	}
}
