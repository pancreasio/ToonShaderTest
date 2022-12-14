Shader "Unlit/UnlitTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(BasicSettings)]
        [Toggle] _XDNT ("Enable ?", Float) = 0
        [Header(ColorSettings)]
        _Color ("Color", Color) = (1,0,0,0)
        [Space(10)]
        [KeywordEnum(Off, Red, Blue, Green)]
        _ColorChoice ("Color Choice", FLoat) = 0
        [Header(MiscSettings)]
        [Enum(Off, 0, Front, 1, Back, 2)]
        _FaceToShow ("Face to show", Float) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull [_FaceToShow]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature _XDNT_ON
            #pragma multi_compile _COLORCHOICE_OFF _COLORCHOICE_RED _COLORCHOICE_BLUE _COLORCHOICE_GREEN

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };
            

            //declarations
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            void fulanito (in float3 normals, out float3 Out)
            {
                Out = normals;
            }

            half3 normalWorld (half3 normal)
            {
                return normalize(mul(unity_ObjectToWorld, float4(normal, 0))).xyz;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = normalize(mul(unity_ObjectToWorld, float4(v.normal,0))).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normals = i.normal;
                //float3 normals = normalWorld(i.normal);

                half3 light = 0;

                fulanito(normals, light);

                return float4(light.rgb, 1);


                // fixed4 col = tex2D(_MainTex, i.uv);

                // #if _COLORCHOICE_OFF
                //     return col * _Color;
                // #elif _COLORCHOICE_RED
                //     return col * float4(1,0,0,1);
                // #elif _COLORCHOICE_BLUE
                //     return col * float4(0,0,1,1);
                // #elif _COLORCHOICE_GREEN
                //     return col * float4(0,1,0,1);
                // #endif
            }
            ENDCG
        }
    }
}
