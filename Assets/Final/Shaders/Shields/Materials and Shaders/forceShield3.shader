// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "forceShield3"
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
			float4 color2 = IsGammaSpace() ? float4(0.1792453,0.02282841,0.09053127,0) : float4(0.02700252,0.001766905,0.008615674,0);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV24 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode24 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV24, _FresnelPower ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth26 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth26 = abs( ( screenDepth26 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DistanceDepthFade ) );
			float4 color29 = IsGammaSpace() ? float4(0.6037736,0.6037736,0.6037736,0) : float4(0.3229691,0.3229691,0.3229691,0);
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
363;73;1102;588;3948.495;-143.7904;2.821125;True;False
Node;AmplifyShaderEditor.CommentaryNode;72;-3096.795,-761.5742;Inherit;False;2023.212;1033.681;Shield;4;71;70;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;69;-3124.931,333.5448;Inherit;False;2192.916;1495.496;Shield effects;3;68;61;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;70;-3031.962,-711.5742;Inherit;False;1140.247;428.3821;Shield distortion;5;12;14;19;16;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;71;-3046.795,-227.2994;Inherit;False;1304.547;499.4061;Shield movement;7;13;18;17;15;20;23;22;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;61;-2680.955,1153.812;Inherit;False;1190.648;675.2294;Depth Fade;7;60;27;26;35;36;28;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;12;-2981.962,-544.6022;Inherit;False;Property;_tiling;tiling;1;0;Create;True;0;0;0;False;0;False;1,1;10,10;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;68;-3074.931,383.5448;Inherit;False;1591.422;736.491;Fresnel;6;62;24;25;2;32;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2624.42,1207.581;Inherit;False;Property;_DistanceDepthFade;DistanceDepthFade;6;0;Create;True;0;0;0;False;0;False;0;83.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-2783.742,-558.5543;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;13;-2996.795,-136.5293;Inherit;False;Property;_PanSpeed;PanSpeed;5;0;Create;True;0;0;0;False;0;False;1,1;-3,-3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-2736.53,-117.9981;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;62;-3024.931,662.0762;Inherit;False;779.1617;438.0871;Pow and variation;6;66;65;64;63;67;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;16;-2376.11,-661.5742;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;d7d99a7080e8e87439948292686f3847;958b03790b2d5cf45b0b0c47e95141e3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-2517.413,-398.3521;Inherit;False;Property;_distortion;distortion;3;0;Create;True;0;0;0;False;0;False;0.7623276;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;60;-2236.09,1395.167;Inherit;False;447.9312;183.7119;Depth Fade intensity;2;47;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-2690.458,161.9466;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2630.955,1320.389;Inherit;False;Property;_PowerDepthFade;PowerDepthFade;14;0;Create;True;0;0;0;False;0;False;0;6.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2904.89,38.16962;Inherit;False;Property;_speed;speed;4;0;Create;True;0;0;0;False;0;False;0.3211765;0.162;0.1;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;26;-2373.139,1203.811;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-2074.325,-490.3813;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2734.716,735.3681;Inherit;False;Property;_FresnelPower;FresnelPower;11;0;Create;True;0;0;0;False;0;False;0;4.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2204.947,568.9529;Inherit;False;Property;_FresnelBias;FresnelBias;7;0;Create;True;0;0;0;False;0;False;0;2.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-2186.09,1463.719;Inherit;False;Property;_Intensidad;Intensidad;15;0;Create;True;0;0;0;False;0;False;0;-81.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;35;-2103.1,1214.801;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2203.452,681.0721;Inherit;False;Property;_FresnelScale;FresnelScale;8;0;Create;True;0;0;0;False;0;False;0;180.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;20;-2421.769,-50.26392;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-2109.275,-177.2994;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;24;-1933.959,623.2581;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-1929.347,1621.241;Inherit;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;0;False;0;False;0.6037736,0.6037736,0.6037736,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1955.699,1445.167;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;55;-779.9294,1025.807;Inherit;False;779.1617;438.0871;Opacity variation;4;59;58;9;10;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;2;-1936.565,433.5448;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;0.1792453,0.02282841,0.09053127,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-682.7061,1315.887;Inherit;False;Property;_maxShield;maxShield;12;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1705.566,-413.7099;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;5798ded558355430c8a9b13ee12a847c;f315990ed8933d242b7b496cd50d19eb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1894.838,-63.79185;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1649.451,1406.987;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-680.5449,1234.888;Inherit;False;Property;_minShield;minShield;9;0;Create;True;0;0;0;False;0;False;0.3;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;9;-594.6361,1080.046;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1651.049,575.5774;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-1391.283,-285.028;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;10;-196.8978,1098.175;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.1;False;4;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2981.422,1004.876;Inherit;False;Property;_maxMultiplier;maxMultiplier;13;0;Create;True;0;0;0;False;0;False;0;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-2392.641,755.4763;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-2985.527,925.9325;Inherit;False;Property;_minMultiplier;minMultiplier;10;0;Create;True;0;0;0;False;0;False;0.3;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;64;-2577.881,891.6475;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.3;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1084.605,964.9926;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinTimeNode;63;-2983.681,745.1635;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;301.4296,201.7523;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;forceShield3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;12;0
WireConnection;15;0;13;0
WireConnection;16;1;14;0
WireConnection;26;0;27;0
WireConnection;21;0;16;0
WireConnection;21;1;14;0
WireConnection;21;2;19;0
WireConnection;35;0;26;0
WireConnection;35;1;36;0
WireConnection;20;0;15;0
WireConnection;20;2;18;0
WireConnection;20;1;17;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;24;1;31;0
WireConnection;24;2;32;0
WireConnection;24;3;33;0
WireConnection;47;0;35;0
WireConnection;47;1;48;0
WireConnection;23;0;22;0
WireConnection;23;1;20;0
WireConnection;28;0;47;0
WireConnection;28;1;29;0
WireConnection;25;0;2;0
WireConnection;25;1;24;0
WireConnection;4;0;3;0
WireConnection;4;1;23;0
WireConnection;10;0;9;4
WireConnection;10;3;58;0
WireConnection;10;4;59;0
WireConnection;67;0;33;0
WireConnection;67;1;64;0
WireConnection;64;0;63;4
WireConnection;64;3;65;0
WireConnection;64;4;66;0
WireConnection;30;0;25;0
WireConnection;30;1;28;0
WireConnection;0;0;4;0
WireConnection;0;2;30;0
WireConnection;0;6;2;0
WireConnection;0;9;10;0
ASEEND*/
//CHKSM=91FED41E51D820BA6C4A928DA33D416B5461918B