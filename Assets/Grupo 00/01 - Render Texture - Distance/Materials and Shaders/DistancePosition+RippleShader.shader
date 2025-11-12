// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distance"
{
	Properties
	{
		_RippleOriginOffset("_RippleOriginOffset", Vector) = (0,0,0,0)
		_RippleSpeed("_RippleSpeed", Range( 0 , 5)) = 0
		_RippleFrequency("_RippleFrequency", Range( 0 , 3)) = 0
		_Texture0("Texture 0", 2D) = "white" {}
		_RippleStartTime("_RippleStartTime", Float) = 0
		_TextureTiling("Texture Tiling", Range( 1 , 10)) = 1
		_PanSpeed("PanSpeed", Range( 0 , 14)) = 0
		_PanDir("PanDir", Vector) = (0,0,0,0)
		_FlowMap("FlowMap", 2D) = "white" {}
		_DistortionWeight("DistortionWeight", Range( 0 , 1)) = 0
		_RippleAmplitude("_RippleAmplitude", Range( 0 , 1)) = 0
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

		uniform float _RippleFrequency;
		uniform float3 _RippleOriginOffset;
		uniform float _RippleStartTime;
		uniform float _RippleSpeed;
		uniform float _RippleAmplitude;
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
			float3 ase_vertex3Pos = v.vertex.xyz;
			float Distance104 = distance( ase_vertex3Pos , _RippleOriginOffset );
			float ElapsedTime116 = ( ( _Time.y - _RippleStartTime ) * _RippleSpeed );
			float3 appendResult139 = (float3(0.0 , _RippleAmplitude , 0.0));
			float3 Wave107 = ( sin( ( _RippleFrequency * Distance104 * ElapsedTime116 ) ) * appendResult139 );
			float Fade128 = ( saturate( ( 1.0 - ( Distance104 * 0.2 ) ) ) * saturate( ( 1.0 - ( ElapsedTime116 * 0.3 ) ) ) );
			v.vertex.xyz += ( Wave107 * Fade128 );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_TextureTiling).xx;
			float2 uv_TexCoord90 = i.uv_texcoord * temp_cast_0;
			float2 lerpResult98 = lerp( uv_TexCoord90 , ( (tex2D( _FlowMap, uv_TexCoord90 )).rg + uv_TexCoord90 ) , _DistortionWeight);
			float2 panner99 = ( 1.0 * _Time.y * ( _PanDir * _PanSpeed ) + lerpResult98);
			o.Albedo = tex2D( _Texture0, panner99 ).rgb;
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
1920;23;1600;816;923.0642;-397.352;1.3;True;True
Node;AmplifyShaderEditor.CommentaryNode;132;-625.0787,-282.077;Inherit;False;1625.527;1582.047;Ripple;4;130;129;110;109;;0.3733909,1,0.3537736,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;129;-575.0787,915.118;Inherit;False;824.2153;314.7375;ElapsedTime;6;86;54;56;116;87;141;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;110;265.3048,899.1639;Inherit;False;685.1437;400.8057;Distance;4;81;78;85;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;54;-463.0741,962.6003;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-480.0704,1058.343;Inherit;False;Property;_RippleStartTime;_RippleStartTime;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;81;315.3047,1115.329;Inherit;False;Property;_RippleOriginOffset;_RippleOriginOffset;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;56;-296.0787,1145.118;Inherit;False;Property;_RippleSpeed;_RippleSpeed;1;0;Create;True;0;0;0;False;0;False;0;3;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;87;-265.4851,995.006;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;78;326.7337,949.1635;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;85;556.2688,1045.441;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-95.63419,1030.373;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;130;-540.5133,-230.0349;Inherit;False;1194.352;490.8994;Fade;10;108;122;123;120;124;119;128;136;137;138;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;131;-657.6405,-1161.745;Inherit;False;1956.259;810.8397;Color;11;89;90;91;92;88;94;93;98;100;99;101;;0.4669811,0.5658722,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;47.73648,1012.303;Inherit;False;ElapsedTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;711.049,1044.7;Inherit;False;Distance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-607.6405,-829.2313;Inherit;False;Property;_TextureTiling;Texture Tiling;5;0;Create;True;0;0;0;False;0;False;1;4;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-474.9009,-165.2599;Inherit;False;104;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-467.7744,60.92505;Inherit;False;116;ElapsedTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;-522.36,309.8529;Inherit;False;1288.646;517.451;Wave;9;4;32;29;105;31;107;117;133;139;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-256.5695,56.76752;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;90;-308.2341,-847.3341;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-243.8794,-154.8264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-350.3221,479.5046;Inherit;False;104;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-396.4291,587.5298;Inherit;False;116;ElapsedTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-404.7085,371.5696;Inherit;False;Property;_RippleFrequency;_RippleFrequency;2;0;Create;True;0;0;0;False;0;False;0;2;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1.467967,491.4774;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-118.8342,697.1497;Inherit;False;Property;_RippleAmplitude;_RippleAmplitude;10;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;120;-96.30436,31.81997;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;137;-83.61429,-179.7739;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;91;-92.4518,-1084.239;Inherit;True;Property;_FlowMap;FlowMap;8;0;Create;True;0;0;0;False;0;False;-1;28225c476c0b68c4cbae177d093a91e0;28225c476c0b68c4cbae177d093a91e0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;4;153.9285,488.924;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;139;168.9462,641.2235;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;138;72.69824,-185.2716;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;92;209.4881,-990.5197;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;124;60.00818,26.32228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;88;131.3462,-651.4611;Inherit;False;589.8474;283.5556;Movimiento;3;97;96;95;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;254.422,-61.24311;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;205.5221,-758.1928;Inherit;False;Property;_DistortionWeight;DistortionWeight;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;193.9862,-466.0656;Inherit;False;Property;_PanSpeed;PanSpeed;6;0;Create;True;0;0;0;False;0;False;0;0;0;14;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;402.0915,-902.3016;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;96;233.0461,-601.4611;Inherit;False;Property;_PanDir;PanDir;7;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;298.0942,491.4658;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;98;561.2299,-837.7404;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;553.6528,-562.1414;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;128;414.4392,-61.62283;Inherit;False;Fade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;468.2246,487.1784;Inherit;False;Wave;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;1115.924,-215.0279;Inherit;False;107;Wave;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;100;667.8917,-1111.745;Inherit;True;Property;_Texture0;Texture 0;3;0;Create;True;0;0;0;False;0;False;d79afcfe4ba835f45a39d670a0fa6fc6;d79afcfe4ba835f45a39d670a0fa6fc6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;99;850.5331,-594.3414;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;1114.924,-141.0279;Inherit;False;128;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;1293.216,-326.3261;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;101;980.4481,-918.3577;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.EdgeLengthTessNode;13;1286.279,-26.02547;Inherit;False;1;0;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;1316.924,-221.0279;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1515.846,-528.2695;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Distance;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;87;0;54;0
WireConnection;87;1;86;0
WireConnection;85;0;78;0
WireConnection;85;1;81;0
WireConnection;141;0;87;0
WireConnection;141;1;56;0
WireConnection;116;0;141;0
WireConnection;104;0;85;0
WireConnection;123;0;122;0
WireConnection;90;0;89;0
WireConnection;136;0;108;0
WireConnection;29;0;31;0
WireConnection;29;1;105;0
WireConnection;29;2;117;0
WireConnection;120;1;123;0
WireConnection;137;1;136;0
WireConnection;91;1;90;0
WireConnection;4;0;29;0
WireConnection;139;1;133;0
WireConnection;138;0;137;0
WireConnection;92;0;91;0
WireConnection;124;0;120;0
WireConnection;119;0;138;0
WireConnection;119;1;124;0
WireConnection;94;0;92;0
WireConnection;94;1;90;0
WireConnection;32;0;4;0
WireConnection;32;1;139;0
WireConnection;98;0;90;0
WireConnection;98;1;94;0
WireConnection;98;2;93;0
WireConnection;97;0;96;0
WireConnection;97;1;95;0
WireConnection;128;0;119;0
WireConnection;107;0;32;0
WireConnection;99;0;98;0
WireConnection;99;2;97;0
WireConnection;101;0;100;0
WireConnection;101;1;99;0
WireConnection;125;0;126;0
WireConnection;125;1;127;0
WireConnection;0;0;101;0
WireConnection;0;9;102;0
WireConnection;0;11;125;0
WireConnection;0;14;13;0
ASEEND*/
//CHKSM=F633DC0A058B3EF9D04815233C0C4584D149B20F