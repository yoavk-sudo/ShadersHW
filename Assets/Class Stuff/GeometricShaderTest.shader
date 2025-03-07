Shader "Unlit/GeometricShaderTest"
{
     Properties
    {
        // Color Property: Used for specifying color values.
        _Color("Main Color", Color) = (1, 1, 1)
        // Color Property with Alpha: Used for specifying color values with an alpha channel.
        _ColorRGBA("My Color with Alpha", Color) = (1, 1, 1, 1)
        // Float Property: Used for specifying single floating-point values.
        _Float("My Float", Range(0, 1)) = 0.5 //with a specified range.
        // Vector Property: Used for specifying vector values (e.g., Vector2, Vector3, Vector4).
        _Vector("My Vector", Vector) = (1, 0, 0, 1)
        // 2D Texture Property: Used for specifying 2D texture maps.
        _MainTex("Main Texture", 2D) = "white" { }
        // Cube Map Property: Used for specifying cube maps.
        _Cube("My Cube Map", CUBE) = "" { }
        // Render Texture Property: Used for specifying render textures.
        _RenderTexture("My Render Texture", 2D) = "" { }
        _Extrude("Extrude Amount", Float) = 0.1
    }
    // specific shader (there might be more then on subshader) under one defined shader.
    SubShader
    {
        Tags { "RenderType"="Opaque" } // common tags: Opaque, Transparent, Overlay,
        LOD 100

        
        //blending parameters
        // SrcFactor is this color DesFactor is the color that is been render before at this vert position
        // syntax: Blend SrcFactor DstFactor
        // FinalColor = (SourceColor � SrcFactor) + (DestinationColor � DstFactor)
        
        Blend SrcAlpha OneMinusSrcAlpha //Specifies the blend mode 
        ZWrite On //writes to the depth buffer 
        ZTest LEqual //depth comparison function 
        
        Cull Back //face culling mode 

        Pass
        {
            
            // order of the code:
            // assume this is like C,
            // so all structures,functions, var - need to be place BEFORE using them!
            
            // variables precision:
            //float    32-bit floating point.
            //half     16-bit floating point.
            //int      32-bit integer.
            //bool     Boolean (true/false).
            
            
            
            
            CGPROGRAM
            #pragma vertex vert // define the name of the vertex func
            #pragma fragment frag // define the name of the fragment func
            #pragma vertex vertGeometryShader
            //#pragma geometry geomShpitz
            #pragma geometry geom

            #include "UnityCG.cginc"

            // Common Semantics
            // POSITION: Vertex position (object space or clip space).
            // NORMAL: Vertex normal (object space).
            // TEXCOORD0, TEXCOORD1, ...: Texture coordinates.
            // COLOR: Vertex color.
            // SV_Position: Special system value for clip space position.
            // SV_Target: Output color for the fragment shader.

            
            // structure to be pass from the app to the vertex
            struct appdata
            {
                // common attribute container naming for per-vertex that can be pass to vert function
                float4 vertex : POSITION; // position in object space
                float3 normal : NORMAL; // normals in object space
                float2 uv : TEXCOORD0; // the first (num 0 ) texture coordinates in the mat
                
                //more attributes
                float4 tang: TANGENT; // tangent direction (xyz) tangent sign (w)
                float4 color : COLOR; 

            };

             // structure to pass from vert to frag after also passing at the rasterizer
            struct v2f
            {
                float4 vertex : SV_POSITION; // use container name or "POSITION" - this will use for clip space pos
                float3 normal : NORMAL; 
                float2 uv: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            struct v2g
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL; 
                float2 uv: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION; // use container name or "POSITION" - this will use for clip space pos
                float3 normal : NORMAL; 
                float2 uv: TEXCOORD0;
                float3 worldPos: TEXCOORD1;
            };

            // declare shaders variables
            // syntax: <PropertyType> <VariableName>;
            sampler2D _MainTex; 
            float4 _MainTex_ST; // Stores tiling (x, y) and offset (z, w).

            float4 _Color;
            float _Extrude;

            // vertex func - first function in the flow
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // from object directly to clip (camera) pos
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(UNITY_MATRIX_M, float4(v.vertex.xyz,1)); // from object to world pos
                o.uv = v.uv;
                return o;
            };
            v2g vertGeometryShader (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // from object directly to clip (camera) pos
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(UNITY_MATRIX_M, float4(v.vertex.xyz,1)); // from object to world pos
                o.uv = v.uv;
                return o;
            }
            [maxvertexcount(6)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                g2f o;
                float3 normal = normalize(cross(input[1].vertex - input[0].vertex, input[2].vertex - input[0].vertex));
                for(int i = 0; i<3; i++)
                {
                    float4 vert = input[i].vertex;
                    vert.xyz += normal * (_Extrude);
                    o.vertex = UnityObjectToClipPos(vert);
                    o.uv = input[i].uv;
                    o.normal = UnityObjectToWorldNormal(normal);
                    o.worldPos = mul(UNITY_MATRIX_M, float4(input[i].vertex.xyz, 1));
                    triStream.Append(o);
                }
                triStream.RestartStrip();
            }

            uniform float3 _TargetPoint;
            [maxvertexcount(9)]
            void geomShpitz(triangle v2g input[3], inout TriangleStream<g2f> triStream, float3 targetPoint)
            {
                g2f o;
                //float3 normal = normalize(cross(input[1].vertex - input[0].vertex, input[2].vertex - input[0].vertex));
                for(int i = 0; i < 3; i++)
                {
                    //float4 vert = input[i].vertex;
                    //vert.xyz += normal * (_Extrude);
                    o.vertex = UnityObjectToClipPos(input[i].vertex);
                    o.uv = input[i].uv;
                    o.normal = UnityObjectToWorldNormal(input[i].normal);
                    o.worldPos = mul(UNITY_MATRIX_M, float4(input[i].vertex.xyz, 1));
                    triStream.Append(o);

                    o.vertex = UnityObjectToClipPos(input[(i + 1) % 3].vertex);
                    o.uv = input[(i + 1) % 3].uv;
                    o.normal = UnityObjectToWorldNormal(input[(i + 1) % 3].normal);
                    o.worldPos = mul(UNITY_MATRIX_M, float4(input[(i + 1) % 3].vertex.xyz, 1));
                    triStream.Append(o);

                    o.vertex = UnityObjectToClipPos(float4(targetPoint, 1.0));
                    o.uv = float2(0.5, 0.5);
                    o.normal = UnityObjectToWorldNormal(normalize(targetPoint - input[i].vertex.xyz));
                    o.worldPos = mul(UNITY_MATRIX_M, float4(targetPoint, 1));
                    triStream.Append(o);

                    triStream.RestartStrip();
                }
            }
            
            // frag func - last function in the flow (after the GPU do the rasterizer)
            float4 frag (g2f i) : SV_Target
            {
                float2 uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                fixed4 texColor = tex2D(_MainTex, uv);
                return texColor;
            }
            ENDCG
        }
    }
}
