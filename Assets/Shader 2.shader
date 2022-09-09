Shader "Custom/New Shader"
{
    Properties
    {
        [MainTexture]
        _BaseMap("Texture", 2D) = "white" {} 
        _Color("Color", Color) = (1, 1, 1, 1)
        _ShadowThreshold("Shadow Threshold", Range(-1, 1)) = 0
        _ShadowColor("Shadow Color", Color) = (0, 0, 0, 0)
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_ws : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
            float4 _Color;
            float _ShadowThreshold;
            float4 _ShadowColor;
            float _Smoothness;
            
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.normal_ws = TransformObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 albedo =  SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) * _Color;

                Light light = GetMainLight();
                float n_dot_l = smoothstep(_ShadowThreshold - _Smoothness, 
                                           _ShadowThreshold + _Smoothness, 
                                           dot(i.normal_ws, light.direction));
                float4 diffuse = lerp(_ShadowColor, albedo, n_dot_l);

                return diffuse * float4(light.color, 1);
            }
            ENDHLSL
        }
    }
}