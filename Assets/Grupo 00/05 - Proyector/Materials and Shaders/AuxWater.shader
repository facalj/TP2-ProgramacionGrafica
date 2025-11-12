// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AuxWater"
{
	Properties
	{
		_TextureTiling("Texture Tiling", Range( 1 , 10)) = 0
		_PanSpeed("PanSpeed", Range( 0 , 14)) = 0
		_PanDir("PanDir", Vector) = (0,0,0,0)
		_FlowMap("FlowMap", 2D) = "white" {}
		_DistortionWeight("DistortionWeight", Range( 0 , 1)) = 0
		_WaterNormal("WaterNormal", 2D) = "bump" {}
		_FresnelPowerWater("FresnelPowerWater", Range( 0.1 , 2)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
		};

		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform sampler2D _WaterNormal;
		uniform float2 _PanDir;
		uniform float _PanSpeed;
		uniform float _TextureTiling;
		uniform sampler2D _FlowMap;
		uniform float _DistortionWeight;
		uniform float _FresnelPowerWater;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_TextureTiling).xx;
			float2 uv_TexCoord10 = i.uv_texcoord * temp_cast_0;
			float4 tex2DNode16 = tex2D( _FlowMap, uv_TexCoord10 );
			float2 appendResult18 = (float2(tex2DNode16.r , tex2DNode16.g));
			float2 lerpResult20 = lerp( uv_TexCoord10 , ( appendResult18 + uv_TexCoord10 ) , _DistortionWeight);
			float2 panner9 = ( 1.0 * _Time.y * ( _PanDir * _PanSpeed ) + lerpResult20);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 screenColor104 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( float4( UnpackNormal( tex2D( _WaterNormal, panner9 ) ) , 0.0 ) + ase_screenPosNorm ).xy);
			float4 color109 = IsGammaSpace() ? float4(0,0.7356222,1,0) : float4(0,0.5004028,1,0);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV105 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode105 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV105, _FresnelPowerWater ) );
			float4 lerpResult107 = lerp( screenColor104 , color109 , fresnelNode105);
			o.Albedo = lerpResult107.rgb;
			o.Alpha = fresnelNode105;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
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
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.screenPos = IN.screenPos;
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
363;73;1100;535;2474.932;1746.846;2.690802;True;False
Node;AmplifyShaderEditor.CommentaryNode;61;-2952.607,-570.6119;Inherit;False;1940.347;800.1974;Toon Water;12;16;17;10;11;18;19;20;21;9;8;6;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2904.358,-104.1817;Inherit;False;Property;_TextureTiling;Texture Tiling;1;0;Create;True;0;0;0;False;0;False;0;4;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2627.305,-273.6039;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-2411.523,-510.5079;Inherit;True;Property;_FlowMap;FlowMap;4;0;Create;True;0;0;0;False;0;False;-1;None;958b03790b2d5cf45b0b0c47e95141e3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;18;-2082.472,-399.3535;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2170.269,-85.84086;Inherit;False;589.8474;283.5556;Movimiento;3;13;12;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;14;-2068.569,-35.8408;Inherit;False;Property;_PanDir;PanDir;3;0;Create;True;0;0;0;False;0;False;0,0;-0.5,-0.55;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;21;-2113.55,-184.4627;Inherit;False;Property;_DistortionWeight;DistortionWeight;5;0;Create;True;0;0;0;False;0;False;0;0.117;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2107.63,99.55463;Inherit;False;Property;_PanSpeed;PanSpeed;2;0;Create;True;0;0;0;False;0;False;0;0.25;0;14;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-1916.98,-328.5709;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;20;-1757.842,-264.0101;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1747.962,3.479096;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;100;-1652.524,-1526.693;Inherit;True;Property;_WaterNormal;WaterNormal;11;0;Create;True;0;0;0;False;0;False;77fdad851e93f394c9f8a1b1a63b56f3;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;9;-1513.169,-121.6121;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;101;-1296.888,-1226.16;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;98;-1412.95,-1441.951;Inherit;True;Property;_TextureSample2;Texture Sample 2;11;0;Create;True;0;0;0;False;0;False;-1;77fdad851e93f394c9f8a1b1a63b56f3;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;110;-1344.645,-974.0198;Inherit;False;Property;_FresnelPowerWater;FresnelPowerWater;12;0;Create;True;0;0;0;False;0;False;1;0;0.1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;-1041.737,-1362.073;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FresnelNode;105;-992.0334,-1043.961;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;104;-804.4166,-1544.71;Inherit;False;Global;_GrabScreen1;Grab Screen 1;12;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;36;-2423.355,403.0937;Inherit;False;1319.66;484.9301;Depth Fate;9;22;23;24;26;25;27;28;29;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;109;-864.5778,-1332.849;Inherit;False;Constant;_Color0;Color 0;12;0;Create;True;0;0;0;False;0;False;0,0.7356222,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;88;-2280.351,1002.715;Inherit;False;1166.364;479.6578;Distortion;9;70;82;84;83;87;85;67;69;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FresnelNode;97;-602.4914,-51.79079;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-542.4,1094.097;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2032.05,490.6834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1773.614,773.6405;Inherit;False;Property;_Pow;Pow;8;0;Create;True;0;0;0;False;0;False;0;3.42;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-364.8121,635.6852;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;69;-1634.522,1081.754;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-1452.923,1081.952;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;32;-333.104,276.2144;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;87;-2045.479,1329.584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;82;-1757.336,1252.376;Inherit;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;0;False;0;False;-1;None;f53512d44b91e954dae7bf028209df1a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;95;2.65652,1081.858;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-565.9492,630.5802;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;8;-1681.012,-543.3542;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;None;dae1f5ea1a06a984c9364c039e91a795;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode;85;-2230.351,1326.172;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-542.5573,828.2398;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;107;-562.3712,-1327.486;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-702.3729,200.1268;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-1902.171,1303.779;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;28;-1676.506,486.9897;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;17;-1970.584,-500.7892;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;29;-1493.59,487.2242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-281.9113,1118.414;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1859.356,487.3705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;67;-1309.894,1075.819;Inherit;False;Global;_GrabScreen0;Grab Screen 0;10;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;30;-1294.346,496.9632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2192.567,767.6844;Inherit;False;Property;_Scale;Scale;7;0;Create;True;0;0;0;False;0;False;0;0.772;0.15;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2246.833,664.7478;Inherit;False;Property;_Bias;Bias;6;0;Create;True;0;0;0;False;0;False;0;0.82;0.3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;22;-2373.356,453.0938;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-2217.967,1214.178;Inherit;False;Property;_Normal;Normal;10;0;Create;True;0;0;0;False;0;False;0;0.028;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;68;-1944.419,1052.715;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;99;-1641.911,-1310.013;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.05,0.03;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;-1359.175,-368.8745;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;96;-265.2519,-1414.239;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;AuxWater;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;11;0
WireConnection;16;1;10;0
WireConnection;18;0;16;1
WireConnection;18;1;16;2
WireConnection;19;0;18;0
WireConnection;19;1;10;0
WireConnection;20;0;10;0
WireConnection;20;1;19;0
WireConnection;20;2;21;0
WireConnection;12;0;14;0
WireConnection;12;1;13;0
WireConnection;9;0;20;0
WireConnection;9;2;12;0
WireConnection;98;0;100;0
WireConnection;98;1;9;0
WireConnection;102;0;98;0
WireConnection;102;1;101;0
WireConnection;105;3;110;0
WireConnection;104;0;102;0
WireConnection;93;0;6;0
WireConnection;93;1;67;0
WireConnection;26;0;22;0
WireConnection;26;1;23;0
WireConnection;90;0;65;0
WireConnection;90;1;30;0
WireConnection;69;0;68;1
WireConnection;69;1;68;2
WireConnection;70;0;69;0
WireConnection;70;1;82;0
WireConnection;32;0;31;0
WireConnection;87;0;85;0
WireConnection;82;5;84;0
WireConnection;95;0;92;0
WireConnection;65;0;31;0
WireConnection;65;1;67;0
WireConnection;92;0;6;0
WireConnection;92;1;67;0
WireConnection;92;2;30;0
WireConnection;107;0;104;0
WireConnection;107;1;109;0
WireConnection;107;2;105;0
WireConnection;31;0;6;0
WireConnection;31;1;30;0
WireConnection;84;0;83;0
WireConnection;84;1;87;0
WireConnection;28;0;27;0
WireConnection;28;1;25;0
WireConnection;17;0;16;0
WireConnection;29;0;28;0
WireConnection;94;0;93;0
WireConnection;94;1;30;0
WireConnection;27;0;26;0
WireConnection;27;1;24;0
WireConnection;67;0;70;0
WireConnection;30;0;29;0
WireConnection;6;0;8;0
WireConnection;6;1;9;0
WireConnection;96;0;107;0
WireConnection;96;9;105;0
ASEEND*/
//CHKSM=CBC9FCDE83EEC666EADB78DE01FEFFFBAF81A916