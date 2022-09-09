Shader "Custom/New Shader"
{
    Properties
    {
        [MainTexture]
        _BaseMap("Texture", 2D) = "white" {} 
        _Color("Color", Color) = (1, 1, 1, 1)
        _Specular("Specular", Range(0, 64)) = 8
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
            float _Specular;
            
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
                float n_dot_l = dot(i.normal_ws, light.direction);
                float4 diffuse = albedo * n_dot_l;

                float3 view_direction = UNITY_MATRIX_IT_MV[2].xyz;
                float3 reflect_direction = reflect(-light.direction, i.normal_ws);
                float spec = pow(max(dot(view_direction, reflect_direction), 0.0), _Specular);
                float4 specular = albedo * spec;

                return (diffuse + specular) * float4(light.color, 1);
            }
            ENDHLSL
        }
    }
}