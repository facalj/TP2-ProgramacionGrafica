// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FadeGlow"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 2
		_FresnelScale("FresnelScale", Range( 0 , 5)) = 1
		_FresnelPower("FresnelPower", Range( 0 , 5)) = 0.1
		_FresnelGlow("FresnelGlow", Float) = 0
		_FadeAmount("FadeAmount", Range( 0 , 1)) = 0.25
		_EdgeAmount("EdgeAmount", Range( 0 , 10)) = 0
		_NoiseTiling("NoiseTiling", Range( 0.1 , 10)) = 0
		_EmissionStrength("EmissionStrength", Range( 0 , 100)) = 1
		_NoisePannerSpeed("NoisePannerSpeed", Range( 0 , 3)) = 0
		_TexturePannerSpeed("TexturePannerSpeed", Range( 0 , 3)) = 0
		_AlbedoTextureColor("AlbedoTextureColor", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform sampler2D _AlbedoTextureColor;
		uniform float _TexturePannerSpeed;
		uniform float _FresnelGlow;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _FadeAmount;
		uniform float _EdgeAmount;
		uniform float _NoisePannerSpeed;
		uniform float _NoiseTiling;
		uniform float _EmissionStrength;
		uniform float _EdgeLength;


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


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


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_0 = (_TexturePannerSpeed).xx;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 appendResult202 = (float4(ase_screenPosNorm.x , ase_screenPosNorm.y , 0.0 , 0.0));
			float2 panner175 = ( _Time.y * temp_cast_0 + appendResult202.xy);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV210 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode210 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV210, _FresnelPower ) );
			float4 ColorParameters162 = ( tex2D( _AlbedoTextureColor, panner175 ) * ( _FresnelGlow * ( 1.0 - fresnelNode210 ) ) );
			o.Albedo = ColorParameters162.rgb;
			Gradient gradient90 = NewGradient( 0, 3, 2, float4( 0.490566, 0, 0.450844, 0.4558785 ), float4( 0.607602, 0.01568625, 0.9921569, 0.720592 ), float4( 0.999729, 0.9973493, 0.9716737, 1 ), 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float FadeAmountReg192 = _FadeAmount;
			float temp_output_198_0 = ( 1.0 - FadeAmountReg192 );
			float2 temp_cast_3 = (_NoisePannerSpeed).xx;
			float2 temp_cast_4 = (_NoiseTiling).xx;
			float2 uv_TexCoord58 = i.uv_texcoord * temp_cast_4;
			float2 panner176 = ( _Time.y * temp_cast_3 + uv_TexCoord58);
			float simplePerlin2D174 = snoise( panner176 );
			simplePerlin2D174 = simplePerlin2D174*0.5 + 0.5;
			float2 temp_cast_5 = (( _NoisePannerSpeed * 4.0 )).xx;
			float2 panner188 = ( _Time.y * temp_cast_5 + uv_TexCoord58);
			float simplePerlin2D185 = snoise( panner188*0.2 );
			simplePerlin2D185 = simplePerlin2D185*0.5 + 0.5;
			float NoiseTexture113 = ( simplePerlin2D174 + simplePerlin2D185 );
			float smoothstepResult80 = smoothstep( FadeAmountReg192 , ( FadeAmountReg192 - ( ( _EdgeAmount / 10.0 ) * temp_output_198_0 ) ) , ( NoiseTexture113 * temp_output_198_0 ));
			float TextureFade111 = smoothstepResult80;
			float4 EmissionParameters157 = ( ( SampleGradient( gradient90, FadeAmountReg192 ) * TextureFade111 ) * _EmissionStrength );
			o.Emission = EmissionParameters157.rgb;
			float lerpResult40 = lerp( 1.0 , 0.0 , TextureFade111);
			o.Alpha = lerpResult40;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc tessellate:tessFunction 

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
				vertexDataFunc( v );
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
351;73;1060;611;1012.85;24.03986;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;116;-508.6061,157.7322;Inherit;False;1505.997;477.7098;Noise Texture;12;113;186;174;185;176;188;190;58;172;212;214;215;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;172;-347.0211,551.1522;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;215;-583.7747,273.6045;Inherit;False;Property;_NoiseTiling;NoiseTiling;10;0;Create;True;0;0;0;False;0;False;0;1;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-318.8868,386.4763;Inherit;False;Property;_NoisePannerSpeed;NoisePannerSpeed;11;0;Create;True;0;0;0;False;0;False;0;1.332016;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;190;28.96352,568.5612;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-62.11932,443.0284;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;58;-289.4231,260.6871;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;45;-1144.689,809.7591;Inherit;False;Property;_FadeAmount;FadeAmount;8;0;Create;True;0;0;0;False;0;False;0.25;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;176;86.78961,260.3865;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;188;97.6181,418.9467;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;115;-506.9877,654.3231;Inherit;False;1502.843;448.0973;Fade + EdgeGlow;10;148;93;85;111;80;114;152;193;197;198;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-863.3112,805.5452;Inherit;False;FadeAmountReg;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;185;294.67,369.1795;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;174;298.3999,255.2663;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;-415.7859,819.8933;Inherit;False;192;FadeAmountReg;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;186;513.55,261.0594;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-462.1655,925.4664;Inherit;False;Property;_EdgeAmount;EdgeAmount;9;0;Create;True;0;0;0;False;0;False;0;5.65;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;198;-161.1823,796.7587;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;714.8333,255.0461;Inherit;False;NoiseTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;93;-144.5387,942.259;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;39.61818,943.3104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-117.6119,723.8042;Inherit;False;113;NoiseTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;164;-511.275,-810.7659;Inherit;False;2272.236;489.1072;Color Parameters.;14;162;51;175;73;202;201;208;209;210;206;203;207;211;213;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;148;219.6173,906.325;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;137.6979,764.6412;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;38.15846,-532.6785;Inherit;False;Property;_FresnelScale;FresnelScale;5;0;Create;True;0;0;0;False;0;False;1;1.56;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;80;442.2837,792.3538;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;201;-466.5534,-760.1377;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;208;42.15862,-434.6788;Inherit;False;Property;_FresnelPower;FresnelPower;6;0;Create;True;0;0;0;False;0;False;0.1;1.9;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;158;-508.6137,-293.8994;Inherit;False;1347.377;415.9562;Emission;8;157;86;87;66;112;91;90;194;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;202;-206.0609,-733.7236;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FresnelNode;210;322.1024,-548.1318;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;654.8652,789.8881;Inherit;False;TextureFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;-351.8869,-588.5237;Inherit;False;Property;_TexturePannerSpeed;TexturePannerSpeed;12;0;Create;True;0;0;0;False;0;False;0;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;73;-247.6754,-465.0433;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;90;-193.4795,-240.2696;Inherit;False;0;3;2;0.490566,0,0.450844,0.4558785;0.607602,0.01568625,0.9921569,0.720592;0.999729,0.9973493,0.9716737,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-438.3575,-151.1469;Inherit;False;192;FadeAmountReg;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;91;-199.0858,-173.1488;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;112;-89.26398,15.29892;Inherit;False;111;TextureFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;175;-6.67882,-732.9377;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;207;566.459,-673.0542;Inherit;False;Property;_FresnelGlow;FresnelGlow;7;0;Create;True;0;0;0;False;0;False;0;3.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;206;580.936,-540.0575;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;116.4786,-48.68434;Inherit;False;Property;_EmissionStrength;EmissionStrength;10;0;Create;True;0;0;0;False;0;False;1;20.49999;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;208.385,-759.6992;Inherit;True;Property;_AlbedoTextureColor;AlbedoTextureColor;13;0;Create;True;0;0;0;False;0;False;-1;None;080f60c2d32d0dc47b30b4ca96913b5a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;810.2718,-664.2752;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;132.1779,-165.4602;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;211;1358.892,-757.6417;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;364.6207,-168.3843;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;1535.671,-763.6761;Inherit;False;ColorParameters;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;157;528.7998,-176.2746;Inherit;False;EmissionParameters;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;170;1473.727,222.1771;Inherit;False;111;TextureFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;1616.129,-44.49136;Inherit;False;162;ColorParameters;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;40;1727.954,179.3136;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;1603.874,39.85957;Inherit;False;157;EmissionParameters;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1909.299,-40.21991;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;FadeGlow;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;2;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;190;0;172;0
WireConnection;212;0;214;0
WireConnection;58;0;215;0
WireConnection;176;0;58;0
WireConnection;176;2;214;0
WireConnection;176;1;172;0
WireConnection;188;0;58;0
WireConnection;188;2;212;0
WireConnection;188;1;190;0
WireConnection;192;0;45;0
WireConnection;185;0;188;0
WireConnection;174;0;176;0
WireConnection;186;0;174;0
WireConnection;186;1;185;0
WireConnection;198;0;193;0
WireConnection;113;0;186;0
WireConnection;93;0;85;0
WireConnection;152;0;93;0
WireConnection;152;1;198;0
WireConnection;148;0;193;0
WireConnection;148;1;152;0
WireConnection;197;0;114;0
WireConnection;197;1;198;0
WireConnection;80;0;197;0
WireConnection;80;1;193;0
WireConnection;80;2;148;0
WireConnection;202;0;201;1
WireConnection;202;1;201;2
WireConnection;210;2;209;0
WireConnection;210;3;208;0
WireConnection;111;0;80;0
WireConnection;91;0;90;0
WireConnection;91;1;194;0
WireConnection;175;0;202;0
WireConnection;175;2;213;0
WireConnection;175;1;73;0
WireConnection;206;0;210;0
WireConnection;51;1;175;0
WireConnection;203;0;207;0
WireConnection;203;1;206;0
WireConnection;66;0;91;0
WireConnection;66;1;112;0
WireConnection;211;0;51;0
WireConnection;211;1;203;0
WireConnection;86;0;66;0
WireConnection;86;1;87;0
WireConnection;162;0;211;0
WireConnection;157;0;86;0
WireConnection;40;2;170;0
WireConnection;0;0;163;0
WireConnection;0;2;159;0
WireConnection;0;9;40;0
ASEEND*/
//CHKSM=D7058F5220B5719369563A2473DE18128B6D8754