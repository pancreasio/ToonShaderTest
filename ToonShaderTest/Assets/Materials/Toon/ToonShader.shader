Shader "Custom/ToonShader"
{
	Properties
	{
		[Header(BasicSettings)]
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		[Header(CelShading)]
		_LightBands ("Light band ammount", float) = 2
		_LightMultiplier ("Light intensity multiplier", float) = 1
		_SpecularColor ("Specular color", Color) = (1,1,1,1)
		_SpecularIntensity ("Specular intensity", float) = 0
		[Header(Outline)]
		_OutlineIntensity ("Outline intensity", float) = 0.02
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf CelShaded fullforwardshadows
		#pragma shader_feature SHADOWED_RIM_ON

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		float _LightBands;
		float _LightMultiplier;
		float4 _SpecularColor;
		float _SpecularIntensity;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;


		struct Input
		{
			float2 uv_MainTex;
			float3 viewDir;
			float3 worldPos;
			float3 worldNormal;
			float3 WorldSpaceLightDir;
		};

		struct SurfaceOutputCelShaded
		{
			float3 Albedo;
			float3 Normal;
			float4 Smoothness;
			float3 Emission;
			fixed Alpha;			
		};

		half4 LightingCelShaded (SurfaceOutputCelShaded s, half3 lightDir, half3 viewDir, half atten)
		{
			//basic shading and light banding division
			half NdotL = clamp(dot(s.Normal, lightDir),0,1);
			half LightBanding = round((NdotL * _LightMultiplier)* _LightBands) / _LightBands;

			//specular calculations
			float3 refl = reflect(-normalize(lightDir), s.Normal);
			float vDotRefl = pow(max(dot(viewDir, refl), 0),32);

			float3 specular = _SpecularColor.rgb * step(1 - s.Smoothness, vDotRefl) * _SpecularIntensity;

			//attenuation
			half stepAtten = round(atten);
			half shadow = LightBanding * stepAtten;

			//coloring
			half3 col = (s.Albedo + specular) * _LightColor0;

			half4 c;

			c.rgb = col * shadow;
			c.a = s.Alpha;
			return c;
		}		

		void surf (Input IN, inout SurfaceOutputCelShaded o)
		{
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Smoothness = _Glossiness;
		}
		ENDCG

		//OUTLINE PASS
		Pass
		{
            Cull Front

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _OutlineColor;
            float _OutlineIntensity;

            struct appdata{
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f{
                float4 position : SV_POSITION;
            };

            v2f vert(appdata v){
                v2f o;
                //convert the vertex positions from object space to clip space so they can be rendered
                o.position = UnityObjectToClipPos(v.vertex + normalize(v.normal) * _OutlineIntensity);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET{
                return _OutlineColor;
            }

            ENDCG
		}
	}
	FallBack "Diffuse"
}
