// Upgrade NOTE: replaced 'UNITY_INSTANCE_ID' with 'UNITY_VERTEX_INPUT_INSTANCE_ID'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/FadeIn"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _MaxDistance("Max Distance", Range(1,50)) = 1
        _Percentage("Percentage", Range(0, 1)) = 0
        _Distance("Distance", Range(0, 50)) = 5
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _NoiseLevel("Noise Level", Range(0,100)) = 1
        _RandomRange("Random Range", Range(1,10)) = 1
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma target 3.0
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float4x4, _RotateMatrix)
            UNITY_DEFINE_INSTANCED_PROP(float, _Percentage)
            UNITY_INSTANCING_BUFFER_END(Props)
            float _MaxDistance;
            float _Distance;
            float _Trigger;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _NoiseTex_TexelSize;
            float _NoiseLevel;
            float _RandomRange;

            struct appdata
            {
                float4  vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                fixed3 col : COLOR2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float2 worldPosXY = mul(unity_ObjectToWorld, float4(0,0,0,1)).xz;
                float noiseValue = saturate(tex2Dlod(_NoiseTex, float4(worldPosXY * _NoiseTex_TexelSize * _NoiseLevel, 1, 0)).r);
                v.vertex = mul(UNITY_ACCESS_INSTANCED_PROP(Props, _RotateMatrix), v.vertex);
                float percentage = UNITY_ACCESS_INSTANCED_PROP(Props, _Percentage);
                v.vertex.xyz *= percentage;
                v.vertex.xyz += (1-percentage) * _Distance * float3(sin(2 * (percentage+noiseValue)), -noiseValue * _RandomRange, 0);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0.rgb;
                o.ambient = ShadeSH9(half4(worldNormal,1));
                o.col = float3(noiseValue,noiseValue,noiseValue);
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                if(UNITY_ACCESS_INSTANCED_PROP(Props, _Percentage) == 0) 
                {
                    clip(-1);
                }
                //return float4(i.col,1);

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 lighting = i.diff + i.ambient;
                col.rgb *= lighting;
                return col;
            }
            ENDCG
        }
    }
}