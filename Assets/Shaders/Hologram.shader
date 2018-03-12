Shader "Custom/HologramShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color",Color) = (0.0,0.0,0.0,1.0)
		_Speed("Speed", float) = 1.0

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
			float _Speed;

			float IsAxis(float3 normal) {
				if ((normal.x >= -0.001 && normal.x <= 0.001) &&
					(normal.z >= -0.001 && normal.z <= 0.001) &&
					((normal.y >= -1.001 && normal.y <= -0.999) ||
					(normal.y >= 0.999 && normal.y <= 1.001))) {
					return 1;
				}
				return 0;
			}			
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _Color;
				if (IsAxis(i.normal) == 1) {
					col.a = 0.25;
					return col;
				}
				col.a = (sin(i.worldVertex.y * 100 + (_Time.y * _Speed)) > 0)? 1.0: 0.25;
				//col.a = abs(noise(i.vertex));

				return col;
			}
			ENDCG
		}
	}
}
