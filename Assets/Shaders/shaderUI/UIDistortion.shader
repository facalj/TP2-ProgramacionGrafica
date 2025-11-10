// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UIDistortion"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
		_Frecuencia("Frecuencia", Range( 0 , 5)) = 0.1
		_RotateTex("RotateTex", 2D) = "white" {}
		_Texture0("Texture 0", 2D) = "white" {}
		_DistortionMask("DistortionMask", 2D) = "white" {}
		_TexFondo("TexFondo", 2D) = "white" {}
		_Texture("Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
		
		Stencil
		{
			Ref [_Stencil]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
			CompFront [_StencilComp]
			PassFront [_StencilOp]
			FailFront Keep
			ZFailFront Keep
			CompBack Always
			PassBack Keep
			FailBack Keep
			ZFailBack Keep
		}


		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		
		Pass
		{
			Name "Default"
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardUtils.cginc"

			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				half2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform fixed4 _TextureSampleAdd;
			uniform float4 _ClipRect;
			uniform sampler2D _MainTex;
			uniform sampler2D _RotateTex;
			uniform sampler2D _DistortionMask;
			uniform sampler2D _TexFondo;
			uniform sampler2D _Texture0;
			uniform float4 _TexFondo_ST;
			uniform float _Frecuencia;
			uniform sampler2D _Texture;
			uniform float4 _Texture_ST;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID( IN );
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				OUT.worldPosition = IN.vertex;
				
				
				OUT.worldPosition.xyz +=  float3( 0, 0, 0 ) ;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float4 temp_output_57_0_g2 = float4(0,0,1,-5);
				float2 temp_output_2_0_g2 = (temp_output_57_0_g2).zw;
				float2 temp_cast_0 = (1.0).xx;
				float2 temp_output_13_0_g2 = ( ( ( IN.texcoord.xy + (temp_output_57_0_g2).xy ) * temp_output_2_0_g2 ) + -( ( temp_output_2_0_g2 - temp_cast_0 ) * 0.5 ) );
				float TimeVar197_g2 = _Time.y;
				float cos17_g2 = cos( TimeVar197_g2 );
				float sin17_g2 = sin( TimeVar197_g2 );
				float2 rotator17_g2 = mul( temp_output_13_0_g2 - float2( 0.5,0.5 ) , float2x2( cos17_g2 , -sin17_g2 , sin17_g2 , cos17_g2 )) + float2( 0.5,0.5 );
				float4 tex2DNode97_g2 = tex2D( _RotateTex, rotator17_g2 );
				float temp_output_115_0_g2 = step( ( (temp_output_13_0_g2).y + -0.5 ) , 0.0 );
				float lerpResult125_g2 = lerp( 1.0 , tex2D( _DistortionMask, IN.texcoord.xy ).g , temp_output_115_0_g2);
				float2 uv_TexFondo = IN.texcoord.xy * _TexFondo_ST.xy + _TexFondo_ST.zw;
				float2 MainUvs222_g1 = uv_TexFondo;
				float4 tex2DNode65_g1 = tex2D( _Texture0, MainUvs222_g1 );
				float4 appendResult82_g1 = (float4(0.0 , tex2DNode65_g1.g , 0.0 , tex2DNode65_g1.r));
				float2 temp_output_84_0_g1 = (UnpackScaleNormal( appendResult82_g1, (0.0 + (sin( ( _Time.y * _Frecuencia ) ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) )).xy;
				float2 temp_output_71_0_g1 = ( temp_output_84_0_g1 + MainUvs222_g1 );
				float4 tex2DNode96_g1 = tex2D( _TexFondo, temp_output_71_0_g1 );
				float2 uv_DistortionMask232_g1 = IN.texcoord.xy;
				float2 uv_Texture = IN.texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
				float4 tex2DNode13 = tex2D( _Texture, uv_Texture );
				float4 temp_output_192_0_g1 = tex2DNode13;
				float4 temp_output_192_0_g2 = ( ( tex2DNode96_g1 * tex2DNode96_g1.a * tex2D( _DistortionMask, uv_DistortionMask232_g1 ).g ) + temp_output_192_0_g1 );
				
				half4 color = ( ( tex2DNode97_g2 * lerpResult125_g2 * tex2DNode97_g2.a ) + temp_output_192_0_g2 );
				
				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
363;73;1100;535;1089.654;258.6254;2.671877;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;30;-1765.888,477.0624;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1638.907,562.9352;Inherit;False;Property;_Frecuencia;Frecuencia;7;0;Create;True;0;0;0;False;0;False;0.1;0.37;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1489.354,393.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-954.0426,-284.5958;Inherit;True;Property;_Texture;Texture;14;0;Create;True;0;0;0;False;0;False;None;80ab37a9e4f49c842903bb43bdd7bcd2;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SinOpNode;31;-1304.568,278.2698;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;-616.5468,-269.4289;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;21;-791.662,252.3019;Inherit;True;Property;_Texture0;Texture 0;9;0;Create;True;0;0;0;False;0;False;None;7c22d29dd2fb52c449a3beef7581f241;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TFHCRemapNode;9;-1166.943,324.6201;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;11;-544.6378,313.0714;Inherit;True;Property;_DistortionMask;DistortionMask;11;0;Create;True;0;0;0;False;0;False;None;596678c53fd54a640bf95ba7dfafd092;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;17;-844.8109,-76.26846;Inherit;True;Property;_TexFondo;TexFondo;13;0;Create;True;0;0;0;False;0;False;None;8088fd32a1778f64b9f14b5af6b3d8c1;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;33;-220.4095,173.144;Inherit;True;Property;_RotateTex;RotateTex;8;0;Create;True;0;0;0;False;0;False;None;ffd5bcaa48c1bc04dbc49b46a85b7fe9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector4Node;38;-245.8414,415.6405;Inherit;False;Constant;_Vector1;Vector 1;8;0;Create;True;0;0;0;False;0;False;0,0,1,-5;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;1;-282.0059,13.32998;Inherit;False;UI-Sprite Effect Layer;0;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,0,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,1,92,0,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TexturePropertyNode;40;-153.0292,713.5217;Inherit;True;Property;_Ramp;Ramp;10;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;23;-799.7841,121.6819;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinTimeNode;10;-1612.732,219.5219;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;24;-1023.085,165.5145;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;32;159.67,368.2186;Inherit;False;UI-Sprite Effect Layer;0;;2;789bf62641c5cfe4ab7126850acc22b8;18,74,2,204,2,191,0,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,0,98,1,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TexturePropertyNode;41;-145.2032,912.6804;Inherit;True;Property;_Flow;Flow;12;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;39;356.7808,699.3835;Inherit;False;UI-Sprite Effect Layer;0;;3;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,0,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,0,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;590.357,264.3778;Float;False;True;-1;2;ASEMaterialInspector;0;4;UIDistortion;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;28;0;30;0
WireConnection;28;1;29;0
WireConnection;31;0;28;0
WireConnection;13;0;3;0
WireConnection;9;0;31;0
WireConnection;1;192;13;0
WireConnection;1;37;17;0
WireConnection;1;75;21;0
WireConnection;1;80;9;0
WireConnection;1;233;11;0
WireConnection;23;1;24;0
WireConnection;32;192;1;0
WireConnection;32;37;33;0
WireConnection;32;101;11;0
WireConnection;32;57;38;0
WireConnection;32;40;30;0
WireConnection;39;192;13;0
WireConnection;39;37;40;0
WireConnection;39;33;41;0
WireConnection;39;40;30;0
WireConnection;0;0;32;0
ASEEND*/
//CHKSM=11A4EEB6DCCE06A68F6D10E8F49CB6ED7DF5F5EB