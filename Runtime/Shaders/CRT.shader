Shader "FullScreen/CRT"
{
    HLSLINCLUDE
    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone xboxseries vulkan metal switch

    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    float _AdditionalBrightness;
    float _ColorDepth;

    float toSrgb1(float c) { return (c < 0.0031308 ? c * 12.92 : 1.055 * pow(c, 0.41666) - 0.055); }
    float3 toSrgb(float3 c) { return float3(toSrgb1(c.r), toSrgb1(c.g), toSrgb1(c.b)); }

    // Modify pixels and write to custom buffer
    float4 FullScreenPassWriter(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float4 color = float4(CustomPassLoadCameraColor(varyings.positionCS.xy, 0), 1.0f);

        // CRTify
        uint columnMod = varyings.positionCS.x % 6;
        uint xMod = columnMod % 3;
        uint yMod = varyings.positionCS.y % 6;

        bool primaryColumn = columnMod < 3;

        if (xMod == 0) color = float4(color.r, 0.0f, 0.0f, 1.0f);
        else if (xMod == 1) color = float4(0.0f, color.g, 0.0f, 1.0f);
        else if (xMod == 2) color = float4(0.0f, 0.0f, color.b, 1.0f);

        if (primaryColumn)
        {
            if (yMod == 2) color = float4(color.rgb * 0.1f, 1.0f);
        }
        else
        {
            if (yMod == 5) color = float4(color.rgb * 0.1f, 1.0f);
        }

        return float4(color.rgb, color.a);
    }

    // Read from custom buffer and output to screen
    float4 FullScreenPassRenderer(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);

        float4 color = CustomPassLoadCustomColor(varyings.positionCS.xy);

        return float4(color.rgb, color.a);
    }
    ENDHLSL

    Properties
    {
        _AdditionalBrightness ("Additional Brightness", Range(-1.0, 2.0)) = 0.0
        _ColorDepth ("Color Depth", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "HDRenderPipeline"
        }
        Pass
        {
            Name "CRT Writer"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
            #pragma fragment FullScreenPassWriter
            ENDHLSL
        }
        Pass
        {
            Name "CRT Renderer"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
            #pragma fragment FullScreenPassRenderer
            ENDHLSL
        }
    }
    Fallback Off
}