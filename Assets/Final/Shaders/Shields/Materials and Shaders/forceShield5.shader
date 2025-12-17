// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "forceShield5"
{
	Properties
	{
		_Texture0("Texture 0", 2D) = "white" {}
		_tiling("tiling", Vector) = (1,1,0,0)
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_distortion("distortion", Range( 0 , 1)) = 0.7623276
		_speed("speed", Range( 0.1 , 0.5)) = 0.3211765
		_PanSpeed("PanSpeed", Vector) = (1,1,0,0)
		_DistanceDepthFade("DistanceDepthFade", Float) = 0
		_FresnelBias("FresnelBias", Float) = 0
		_FresnelScale("FresnelScale", Float) = 0
		_minShield("minShield", Range( 0 , 1)) = 0.3
		_FresnelPower("FresnelPower", Float) = 0
		_maxShield("maxShield", Range( 0 , 1)) = 0
		_PowerDepthFade("PowerDepthFade", Float) = 0
		_Intensidad("Intensidad", Float) = 0
		_minMultiplier("minMultiplier", Range( 0 , 10)) = 1
		_maxMultiplier("maxMultiplier", Range( 0 , 10)) = 1.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			float4 screenPos;
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
		};

		uniform sampler2D _Texture0;
		uniform sampler2D _TextureSample1;
		uniform float2 _tiling;
		uniform float _distortion;
		uniform float _speed;
		uniform float2 _PanSpeed;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _minMultiplier;
		uniform float _maxMultiplier;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DistanceDepthFade;
		uniform float _PowerDepthFade;
		uniform float _Intensidad;
		uniform float _minShield;
		uniform float _maxShield;

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + d;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_TexCoord14 = i.uv_texcoord * _tiling;
			float4 lerpResult21 = lerp( tex2D( _TextureSample1, uv_TexCoord14 ) , float4( uv_TexCoord14, 0.0 , 0.0 ) , _distortion);
			float2 temp_cast_1 = (_speed).xx;
			float2 uv_TexCoord15 = i.uv_texcoord * _PanSpeed;
			float2 panner20 = ( _Time.y * temp_cast_1 + uv_TexCoord15);
			o.Albedo = tex2D( _Texture0, ( ( lerpResult21 + float4( panner20, 0.0 , 0.0 ) ) + float4( panner20, 0.0 , 0.0 ) ).rg ).rgb;
			float4 color2 = IsGammaSpace() ? float4(0.3964485,0,0.5377358,0) : float4(0.1303928,0,0.2506461,0);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV24 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode24 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV24, ( _FresnelPower * (_minMultiplier + (_SinTime.w - -1.0) * (_maxMultiplier - _minMultiplier) / (1.0 - -1.0)) ) ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth26 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth26 = abs( ( screenDepth26 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DistanceDepthFade ) );
			float4 color29 = IsGammaSpace() ? float4(1,0,0.3387189,0) : float4(1,0,0.09389471,0);
			o.Emission = ( ( color2 * fresnelNode24 ) + ( ( pow( distanceDepth26 , _PowerDepthFade ) * _Intensidad ) * color29 ) ).rgb;
			o.Transmission = color2.rgb;
			o.Alpha = (_minShield + (_SinTime.w - -1.0) * (_maxShield - _minShield) / (1.0 - -1.0));
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom alpha:fade keepalpha fullforwardshadows exclude_path:deferred 

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
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
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
363;73;1102;588;4081.138;1730.548;6.178336;True;False
Node;AmplifyShaderEditor.CommentaryNode;62;-2809.364,99.53769;Inherit;False;1768.137;1360.479;Shield effect;3;61;59;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;51;-2882.557,-930.5323;Inherit;False;1906.7;969.743;Shield;4;50;49;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;-2759.364,149.5377;Inherit;False;1439.159;679.0386;Fresnel;6;31;32;24;2;25;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;49;-2832.557,-880.5323;Inherit;False;1140.241;428.3822;Distortion;5;12;14;16;19;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;61;-2627.739,863.8502;Inherit;False;1299.763;596.1676;Depth fade;7;60;26;35;27;36;28;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;50;-2710.903,-419.425;Inherit;False;1293.049;458.6358;Movement;7;22;13;15;17;18;20;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;12;-2782.557,-713.5604;Inherit;False;Property;_tiling;tiling;1;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;52;-2709.364,434.3281;Inherit;False;682.3767;380.2093;Pow and variation;6;58;57;56;55;54;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2689.184,635.7461;Inherit;False;Property;_minMultiplier;minMultiplier;14;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2571.205,972.5846;Inherit;False;Property;_DistanceDepthFade;DistanceDepthFade;6;0;Create;True;0;0;0;False;0;False;0;5.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2689.702,713.4168;Inherit;False;Property;_maxMultiplier;maxMultiplier;15;0;Create;True;0;0;0;False;0;False;1.5;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-2584.337,-727.5124;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinTimeNode;54;-2690.565,483.2899;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;13;-2660.903,-369.425;Inherit;False;Property;_PanSpeed;PanSpeed;5;0;Create;True;0;0;0;False;0;False;1,1;7,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;18;-2568.999,-194.7263;Inherit;False;Property;_speed;speed;4;0;Create;True;0;0;0;False;0;False;0.3211765;0.378;0.1;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2318.01,-567.3101;Inherit;False;Property;_distortion;distortion;3;0;Create;True;0;0;0;False;0;False;0.7623276;0.173;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-2354.569,-70.9493;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2577.739,1085.392;Inherit;False;Property;_PowerDepthFade;PowerDepthFade;12;0;Create;True;0;0;0;False;0;False;0;-1.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-2176.709,-830.5323;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;d7d99a7080e8e87439948292686f3847;d7d99a7080e8e87439948292686f3847;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;26;-2193.726,913.8502;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;57;-2344.814,600.3039;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;60;-2022.208,1048.719;Inherit;False;420.6926;183.3199;Intensity;2;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2376.651,475.0904;Inherit;False;Property;_FresnelPower;FresnelPower;10;0;Create;True;0;0;0;False;0;False;0;3.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-2400.641,-350.8938;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;35;-1921.726,929.8502;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-2160.356,480.8751;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1972.208,1112.867;Inherit;False;Property;_Intensidad;Intensidad;13;0;Create;True;0;0;0;False;0;False;0;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1983.749,423.5373;Inherit;False;Property;_FresnelScale;FresnelScale;8;0;Create;True;0;0;0;False;0;False;0;53.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1983.749,311.5374;Inherit;False;Property;_FresnelBias;FresnelBias;7;0;Create;True;0;0;0;False;0;False;0;3.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;20;-2085.882,-283.1598;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;21;-1874.926,-659.3393;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;24;-1775.747,391.5373;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-1775.747,199.5378;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;0.3964485,0,0.5377358,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1723.594,-354.3387;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;77;-519.8027,503.7234;Inherit;False;779.1617;438.0871;Opacity variation;4;80;79;9;10;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1769.055,1098.72;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-1741.705,1252.217;Inherit;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;0;False;0;False;1,0,0.3387189,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinTimeNode;9;-407.5987,564.7264;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;80;-472.296,817.5834;Inherit;False;Property;_maxShield;maxShield;11;0;Create;True;0;0;0;False;0;False;0;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-472.296,736.5835;Inherit;False;Property;_minShield;minShield;9;0;Create;True;0;0;0;False;0;False;0.3;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1495.515,966.1854;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1570.444,-266.6142;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1594.098,-713.7386;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;5798ded558355430c8a9b13ee12a847c;b23676ff9cac20a4c9c7b9333f055f1b;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1487.751,343.5374;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-1293.557,-534.3202;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;10;-1.976999,702.5742;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1193.817,739.9766;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;166.0776,-53.82829;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;forceShield5;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;12;0
WireConnection;16;1;14;0
WireConnection;26;0;27;0
WireConnection;57;0;54;4
WireConnection;57;3;55;0
WireConnection;57;4;56;0
WireConnection;15;0;13;0
WireConnection;35;0;26;0
WireConnection;35;1;36;0
WireConnection;58;0;33;0
WireConnection;58;1;57;0
WireConnection;20;0;15;0
WireConnection;20;2;18;0
WireConnection;20;1;17;0
WireConnection;21;0;16;0
WireConnection;21;1;14;0
WireConnection;21;2;19;0
WireConnection;24;1;31;0
WireConnection;24;2;32;0
WireConnection;24;3;58;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;47;0;35;0
WireConnection;47;1;48;0
WireConnection;28;0;47;0
WireConnection;28;1;29;0
WireConnection;23;0;22;0
WireConnection;23;1;20;0
WireConnection;25;0;2;0
WireConnection;25;1;24;0
WireConnection;4;0;3;0
WireConnection;4;1;23;0
WireConnection;10;0;9;4
WireConnection;10;3;79;0
WireConnection;10;4;80;0
WireConnection;30;0;25;0
WireConnection;30;1;28;0
WireConnection;0;0;4;0
WireConnection;0;2;30;0
WireConnection;0;6;2;0
WireConnection;0;9;10;0
ASEEND*/
//CHKSM=2228ABE8E650874F4A12ECE87E2ED2EACA6FE0B8