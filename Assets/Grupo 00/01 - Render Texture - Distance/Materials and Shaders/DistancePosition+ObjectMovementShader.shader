// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distance"
{
	Properties
	{
		_WaveOriginOffset("_WaveOriginOffset", Vector) = (5,5,0,0)
		_WaveSpeed("_WaveSpeed", Range( 0 , 5)) = 3
		_Texture0("Texture 0", 2D) = "white" {}
		_WaveFrequency("_WaveFrequency", Range( 0 , 5)) = 2
		_TextureTiling("Texture Tiling", Range( 1 , 10)) = 0
		_PanSpeed("PanSpeed", Range( 0 , 14)) = 0
		_PanDir("PanDir", Vector) = (0,0,0,0)
		_FlowMap("FlowMap", 2D) = "white" {}
		_DistortionWeight("DistortionWeight", Range( 0 , 1)) = 0
		_WaveAmplitude("_WaveAmplitude", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _WaveSpeed;
		uniform float3 _WaveOriginOffset;
		uniform float _WaveFrequency;
		uniform float _WaveAmplitude;
		uniform sampler2D _Texture0;
		uniform float2 _PanDir;
		uniform float _PanSpeed;
		uniform float _TextureTiling;
		uniform sampler2D _FlowMap;
		uniform float _DistortionWeight;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, 1.0);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float mulTime54 = _Time.y * _WaveSpeed;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult105 = (float4(0.0 , _WaveAmplitude , 0.0 , 0.0));
			v.vertex.xyz += ( sin( ( mulTime54 + ( distance( ase_vertex3Pos , _WaveOriginOffset ) * _WaveFrequency ) ) ) * appendResult105 ).xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_TextureTiling).xx;
			float2 uv_TexCoord91 = i.uv_texcoord * temp_cast_0;
			float2 lerpResult99 = lerp( uv_TexCoord91 , ( (tex2D( _FlowMap, uv_TexCoord91 )).rg + uv_TexCoord91 ) , _DistortionWeight);
			float2 panner101 = ( 1.0 * _Time.y * ( _PanDir * _PanSpeed ) + lerpResult99);
			o.Albedo = tex2D( _Texture0, panner101 ).rgb;
			o.Alpha = 0.5;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
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
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
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
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
1920;23;1600;816;1503.951;310.7776;1.320453;True;True
Node;AmplifyShaderEditor.RangedFloatNode;90;-1831.015,-431.6793;Inherit;False;Property;_TextureTiling;Texture Tiling;4;0;Create;True;0;0;0;False;0;False;0;4;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;91;-1553.962,-601.1017;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;78;-1148.659,172.8179;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;81;-1160.088,338.9837;Inherit;False;Property;_WaveOriginOffset;_WaveOriginOffset;0;0;Create;True;0;0;0;False;0;False;5,5,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;92;-1338.18,-838.0056;Inherit;True;Property;_FlowMap;FlowMap;7;0;Create;True;0;0;0;False;0;False;-1;None;28225c476c0b68c4cbae177d093a91e0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;31;-820.3803,388.7418;Inherit;False;Property;_WaveFrequency;_WaveFrequency;3;0;Create;True;0;0;0;False;0;False;2;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;89;-1114.382,-405.2286;Inherit;False;589.8474;283.5556;Movimiento;3;98;97;95;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-896.2088,78.98833;Inherit;False;Property;_WaveSpeed;_WaveSpeed;1;0;Create;True;0;0;0;False;0;False;3;3;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;103;-1036.24,-744.2868;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;85;-919.1258,269.0959;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-646.9789,271.5418;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;96;-1040.206,-511.9604;Inherit;False;Property;_DistortionWeight;DistortionWeight;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;54;-687.2031,156.4435;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;95;-1012.682,-355.2285;Inherit;False;Property;_PanDir;PanDir;6;0;Create;True;0;0;0;False;0;False;0,0;-0.5,-0.55;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;97;-1051.742,-219.833;Inherit;False;Property;_PanSpeed;PanSpeed;5;0;Create;True;0;0;0;False;0;False;0;0.25;0;14;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-843.6365,-656.0687;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-442.2053,413.4563;Inherit;False;Property;_WaveAmplitude;_WaveAmplitude;9;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;99;-684.4985,-591.5078;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-442.9208,255.9284;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-692.0756,-315.9087;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;101;-458.5006,-466.0872;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;105;-194.1196,348.7234;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexturePropertyNode;100;-708.4446,-842.1097;Inherit;True;Property;_Texture0;Texture 0;2;0;Create;True;0;0;0;False;0;False;None;d79afcfe4ba835f45a39d670a0fa6fc6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SinOpNode;4;-293.4281,255.4233;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;155.2223,126.5686;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-51.2627,252.6073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;13;82.35773,382.351;Inherit;False;1;0;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;102;-257.0858,-679.6035;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;364,5.02752;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Distance;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;91;0;90;0
WireConnection;92;1;91;0
WireConnection;103;0;92;0
WireConnection;85;0;78;0
WireConnection;85;1;81;0
WireConnection;29;0;85;0
WireConnection;29;1;31;0
WireConnection;54;0;56;0
WireConnection;94;0;103;0
WireConnection;94;1;91;0
WireConnection;99;0;91;0
WireConnection;99;1;94;0
WireConnection;99;2;96;0
WireConnection;55;0;54;0
WireConnection;55;1;29;0
WireConnection;98;0;95;0
WireConnection;98;1;97;0
WireConnection;101;0;99;0
WireConnection;101;2;98;0
WireConnection;105;1;104;0
WireConnection;4;0;55;0
WireConnection;32;0;4;0
WireConnection;32;1;105;0
WireConnection;102;0;100;0
WireConnection;102;1;101;0
WireConnection;0;0;102;0
WireConnection;0;9;87;0
WireConnection;0;11;32;0
WireConnection;0;14;13;0
ASEEND*/
//CHKSM=FA2623B1C1D7B9FEB4F0A214208280432BFECB72