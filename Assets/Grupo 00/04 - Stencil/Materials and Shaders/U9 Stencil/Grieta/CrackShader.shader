// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Crack"
{
	Properties
	{
		_TextureLava("TextureLava", 2D) = "white" {}
		_DirtTexture("DirtTexture", 2D) = "white" {}
		_YBordeMax("Y Borde Max", Range( -2 , 0)) = 0
		_YFondoMin("Y Fondo Min", Range( -2 , 0)) = -1
		_GlowColor("GlowColor", Color) = (0.8962264,0.6841329,0.09723213,0)
		_GlowIntensity("GlowIntensity", Range( 0 , 10)) = 0
		_LavaIntensity("LavaIntensity", Range( 0 , 10)) = 0
		_GlowNoiseScale("GlowNoiseScale", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		ZTest Always
		Stencil
		{
			Ref 1
			Comp Equal
		}
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
		};

		uniform sampler2D _TextureLava;
		uniform float _LavaIntensity;
		uniform sampler2D _DirtTexture;
		uniform float4 _DirtTexture_ST;
		uniform float4 _GlowColor;
		uniform float _GlowNoiseScale;
		uniform float _YFondoMin;
		uniform float _YBordeMax;
		uniform float _GlowIntensity;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 panner13 = ( 1.0 * _Time.y * float2( 0.1,0.05 ) + i.uv_texcoord);
			float3 ase_worldNormal = i.worldNormal;
			float dotResult5 = dot( ase_worldNormal , float3( 0,1,0 ) );
			float smoothstepResult6 = smoothstep( 0.8 , 0.9 , dotResult5);
			float MaskLava9 = smoothstepResult6;
			float2 uv_DirtTexture = i.uv_texcoord * _DirtTexture_ST.xy + _DirtTexture_ST.zw;
			float MaskTierra10 = ( 1.0 - smoothstepResult6 );
			float2 panner38 = ( 1.0 * _Time.y * float2( 0.2,0.5 ) + float2( 0,0 ));
			float simplePerlin2D37 = snoise( panner38*_GlowNoiseScale );
			simplePerlin2D37 = simplePerlin2D37*0.5 + 0.5;
			float3 ase_worldPos = i.worldPos;
			float smoothstepResult17 = smoothstep( _YFondoMin , _YBordeMax , ase_worldPos.y);
			float4 temp_output_32_0 = ( ( tex2D( _TextureLava, panner13 ) * MaskLava9 * _LavaIntensity ) + ( tex2D( _DirtTexture, uv_DirtTexture ) * MaskTierra10 ) + ( ( _GlowColor * ( simplePerlin2D37 * ( 1.0 - smoothstepResult17 ) ) * _GlowIntensity ) * MaskTierra10 ) );
			o.Albedo = temp_output_32_0.rgb;
			o.Emission = temp_output_32_0.rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
-214;239;1904;1338;2332.619;-345.559;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;7;-1025.343,-653.7578;Inherit;False;952.71;423.48;Masks;6;9;10;6;5;1;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;36;-1839.319,779.3652;Inherit;False;1122.829;379.257;MaskGlowPosition;7;39;20;17;18;19;16;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-975.3423,-603.7578;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;2;-1789.319,829.3652;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;18;-1642.415,970.1727;Inherit;False;Property;_YFondoMin;Y Fondo Min;3;0;Create;True;0;0;0;False;0;False;-1;-1.428;-2;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1642.185,1054.366;Inherit;False;Property;_YBordeMax;Y Borde Max;2;0;Create;True;0;0;0;False;0;False;0;-0.779;-2;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;41;-1842.717,471.7737;Inherit;False;Constant;_GlowPannerSpeed;GlowPannerSpeed;7;0;Create;True;0;0;0;False;0;False;0.2,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.BreakToComponentsNode;16;-1534.319,837.3652;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;5;-760.3419,-519.7577;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;17;-1317.319,857.3652;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;6;-598.3419,-489.7577;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1533.619,637.559;Inherit;False;Property;_GlowNoiseScale;GlowNoiseScale;7;0;Create;True;0;0;0;False;0;False;1;0.66;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;38;-1568.55,470.8669;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;11;-506.3419,-321.7577;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-1276.216,-91.88073;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;31;-1019.468,-195.5502;Inherit;False;893.6472;328.16;LavaTexture;5;14;15;12;13;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;37;-1278.186,611.6668;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;20;-1102.019,870.2652;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-806.6048,495.5941;Inherit;False;Property;_GlowColor;GlowColor;4;0;Create;True;0;0;0;False;0;False;0.8962264,0.6841329,0.09723213,0;0.8962264,0.6841329,0.09723148,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-296.3417,-495.7577;Inherit;False;MaskLava;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-869.5894,841.5523;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-303.3417,-322.7577;Inherit;False;MaskTierra;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-973.7734,1216.08;Inherit;False;Property;_GlowIntensity;GlowIntensity;5;0;Create;True;0;0;0;False;0;False;0;3.02;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;13;-995.4682,-93.55018;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.05;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;30;-1021.884,149.6579;Inherit;False;643.3459;315.3075;DirtTextures;3;27;28;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-507.4682,-67.55021;Inherit;False;9;MaskLava;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;27;-971.8841,199.658;Inherit;True;Property;_DirtTexture;DirtTexture;1;0;Create;True;0;0;0;False;0;False;-1;ceb1bacd3e5dc9b4cb4b85eb1a74cfb6;ceb1bacd3e5dc9b4cb4b85eb1a74cfb6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;25;-335.354,831.4601;Inherit;False;10;MaskTierra;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-793.4683,-149.5502;Inherit;True;Property;_TextureLava;TextureLava;0;0;Create;True;0;0;0;False;0;False;-1;8f0e7a62f0868d045b42745fd9952c2c;8f0e7a62f0868d045b42745fd9952c2c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;34;-576.3702,40.0466;Inherit;False;Property;_LavaIntensity;LavaIntensity;6;0;Create;True;0;0;0;False;0;False;0;1.27;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-480.5219,689.9727;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-659.5137,357.8055;Inherit;False;10;MaskTierra;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-546.078,243.0349;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-262.354,687.4601;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-327.3611,-115.8371;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-114.6155,221.2193;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;187.1842,196.7871;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Crack;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;7;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;5;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;16;0;2;0
WireConnection;5;0;1;0
WireConnection;17;0;16;1
WireConnection;17;1;18;0
WireConnection;17;2;19;0
WireConnection;6;0;5;0
WireConnection;38;2;41;0
WireConnection;11;0;6;0
WireConnection;37;0;38;0
WireConnection;37;1;43;0
WireConnection;20;0;17;0
WireConnection;9;0;6;0
WireConnection;39;0;37;0
WireConnection;39;1;20;0
WireConnection;10;0;11;0
WireConnection;13;0;33;0
WireConnection;12;1;13;0
WireConnection;22;0;21;0
WireConnection;22;1;39;0
WireConnection;22;2;24;0
WireConnection;28;0;27;0
WireConnection;28;1;29;0
WireConnection;26;0;22;0
WireConnection;26;1;25;0
WireConnection;14;0;12;0
WireConnection;14;1;15;0
WireConnection;14;2;34;0
WireConnection;32;0;14;0
WireConnection;32;1;28;0
WireConnection;32;2;26;0
WireConnection;0;0;32;0
WireConnection;0;2;32;0
ASEEND*/
//CHKSM=9C9FAD77D6784088F3E4728CB64B819E612C002A