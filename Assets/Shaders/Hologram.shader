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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 worldVertex : W_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.worldVertex = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}
			
			sampler2D _MainTex;
			float4 _Color;
			float _Speed;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _Color;
				col.a = (sin(i.worldVertex.y * 100 + (_Time.y * _Speed)) > 0)? 1.0: 0.25;
				//col.a = abs(noise(i.vertex));

				return col;
			}
			ENDCG
		}
	}
}
