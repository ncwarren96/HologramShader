Shader "Custom/OutlineEdges"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (0.4,0.4,0.4,1)
		_OutlineColor("Outline Color",Color) = (0,0,0,1)
		_OutlineWidth("Outline Width", Range(1.0,5.0)) = 1.01
	}


		CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal: NORMAL;
		};

		struct v2f
		{
			float4 pos: POSITION;
			float3 normal: NORMAL;
		};

		float _OutlineWidth;
		float4 _OutlineColor;

		v2f vert (appdata v)//rendering the normal mesh but bigger, takes the vertexes and multiplies them by thier normal, thus increasting it size
		{
			v.vertex.xyz *= _OutlineWidth;

			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass //Render the outline
		{

			ZWrite Off


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			half4 frag(v2f i): COLOR
			{
				return _OutlineColor;
			}

			ENDCG
		}

		Pass //normal rendering, using a surface shader approach
		{
			ZWrite On

			Material
			{
				Diffuse[_Color]
				Ambient[_Color]
			}

			Lighting On

			SetTexture[_MainTex]
			{
				Combine previous * primary DOUBLE
			}

		}
	}
}
