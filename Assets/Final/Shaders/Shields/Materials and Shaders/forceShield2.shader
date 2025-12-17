// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "forceShield2"
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
		_FresnelPower("FresnelPower", Float) = 0
		_minShield("minShield", Range( 0 , 1)) = 0.3
		_PowerDepthFade("PowerDepthFade", Float) = 0
		_maxShield("maxShield", Range( 0 , 1)) = 0
		_Intensidad("Intensidad", Float) = 0
		_minMultiplier("minMultiplier", Range( 0 , 10)) = 1
		_maxMultiplier("maxMultiplier", Range( 0 , 10)) = 1.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
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
			float4 color2 = IsGammaSpace() ? float4(0.001775886,0.3137255,0,0) : float4(0.0001374525,0.08021983,0,0);
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
			float4 color29 = IsGammaSpace() ? float4(0,1,0.2937734,0) : float4(0,1,0.07019372,0);
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
363;73;1102;588;1798.529;-172.2597;1.633981;True;False
Node;AmplifyShaderEditor.CommentaryNode;60;-2988.239,-58.21863;Inherit;False;1660.872;1423.012;Shield effects;3;58;56;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;54;-2977.854,-1073.68;Inherit;False;1896.829;975.2414;Shield;4;53;52;3;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;53;-2927.854,-1028.981;Inherit;False;1139.214;400.0518;Shield distortion;5;21;16;19;14;12;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-2976.647,-10.35235;Inherit;False;1387.798;656.7552;Fresnel;6;32;25;24;2;31;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;52;-2720.087,-599.7062;Inherit;False;1242.494;429.7021;Shield Movement;7;22;23;20;15;18;13;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;12;-2877.854,-850.9811;Inherit;False;Property;_tiling;tiling;1;0;Create;True;0;0;0;False;0;False;1,1;3,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;58;-2805.225,688.8959;Inherit;False;1195.311;562.6801;Depth Fade;7;29;35;26;36;27;28;57;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;55;-2947.153,251.8394;Inherit;False;682.3767;380.2093;Pow and variation;6;50;63;49;51;33;64;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2927.491,530.9269;Inherit;False;Property;_maxMultiplier;maxMultiplier;15;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2926.973,453.2562;Inherit;False;Property;_minMultiplier;minMultiplier;14;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;49;-2928.354,300.8008;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;13;-2670.087,-549.7063;Inherit;False;Property;_PanSpeed;PanSpeed;5;0;Create;True;0;0;0;False;0;False;1,1;3,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;27;-2748.691,742.6661;Inherit;False;Property;_DistanceDepthFade;DistanceDepthFade;6;0;Create;True;0;0;0;False;0;False;0;9.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-2685.854,-866.9811;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;17;-2366.087,-245.7065;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2413.854,-706.9811;Inherit;False;Property;_distortion;distortion;3;0;Create;True;0;0;0;False;0;False;0.7623276;0.7623276;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2679.476,295.4384;Inherit;False;Property;_FresnelPower;FresnelPower;9;0;Create;True;0;0;0;False;0;False;0;10.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;26;-2497.412,738.8959;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;50;-2582.603,417.814;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-2285.854,-978.9809;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;d7d99a7080e8e87439948292686f3847;d7d99a7080e8e87439948292686f3847;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;57;-2341.403,869.9609;Inherit;False;455.288;183.4519;Depth Fade intensity;2;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2755.225,855.4742;Inherit;False;Property;_PowerDepthFade;PowerDepthFade;11;0;Create;True;0;0;0;False;0;False;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2590.087,-373.7062;Inherit;False;Property;_speed;speed;4;0;Create;True;0;0;0;False;0;False;0.3211765;0.174;0.1;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-2414.087,-533.7062;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;35;-2227.374,749.8854;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-2398.145,298.386;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2291.403,938.2525;Inherit;False;Property;_Intensidad;Intensidad;13;0;Create;True;0;0;0;False;0;False;0;0.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-1981.854,-802.9811;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;20;-2094.088,-469.7061;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2240,240;Inherit;False;Property;_FresnelScale;FresnelScale;8;0;Create;True;0;0;0;False;0;False;0;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2240,144;Inherit;False;Property;_FresnelBias;FresnelBias;7;0;Create;True;0;0;0;False;0;False;0;1.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;59;-1111.993,443.6755;Inherit;False;779.1617;438.0871;Opacity variation;4;9;10;61;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1796.273,-497.5024;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-2053.655,919.9609;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-2060.654,1069.122;Inherit;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;0;False;0;False;0,1,0.2937734,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;24;-2032,224;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-2032,32;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;0.001775886,0.3137255,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;61;-1064.486,676.5356;Inherit;False;Property;_minShield;minShield;10;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1686.724,-892.9799;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;5798ded558355430c8a9b13ee12a847c;61c0b9c0523734e0e91bc6043c72a490;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1646.083,-396.1284;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1779.142,781.0909;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1744,176;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinTimeNode;9;-981.9182,483.381;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-1064.486,757.5356;Inherit;False;Property;_maxShield;maxShield;12;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1479.957,432.1003;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-1398.724,-732.9799;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;10;-623.6297,567.8911;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.3;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-149.33,128.1257;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;forceShield2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;12;0
WireConnection;26;0;27;0
WireConnection;50;0;49;4
WireConnection;50;3;63;0
WireConnection;50;4;64;0
WireConnection;16;1;14;0
WireConnection;15;0;13;0
WireConnection;35;0;26;0
WireConnection;35;1;36;0
WireConnection;51;0;33;0
WireConnection;51;1;50;0
WireConnection;21;0;16;0
WireConnection;21;1;14;0
WireConnection;21;2;19;0
WireConnection;20;0;15;0
WireConnection;20;2;18;0
WireConnection;20;1;17;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;47;0;35;0
WireConnection;47;1;48;0
WireConnection;24;1;31;0
WireConnection;24;2;32;0
WireConnection;24;3;51;0
WireConnection;23;0;22;0
WireConnection;23;1;20;0
WireConnection;28;0;47;0
WireConnection;28;1;29;0
WireConnection;25;0;2;0
WireConnection;25;1;24;0
WireConnection;30;0;25;0
WireConnection;30;1;28;0
WireConnection;4;0;3;0
WireConnection;4;1;23;0
WireConnection;10;0;9;4
WireConnection;10;3;61;0
WireConnection;10;4;62;0
WireConnection;0;0;4;0
WireConnection;0;2;30;0
WireConnection;0;6;2;0
WireConnection;0;9;10;0
ASEEND*/
//CHKSM=FA76ED3301F9F891FF2DF2D2988ED2ED3D113A65