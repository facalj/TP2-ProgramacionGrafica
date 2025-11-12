// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "UICombine"
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
		_Texture1("Texture 1", 2D) = "white" {}
		_RotScale("RotScale", Vector) = (0,0,1,-5)
		_RotateTex("RotateTex", 2D) = "white" {}
		_Texture2("Texture 2", 2D) = "white" {}
		_Texture0("Texture 0", 2D) = "white" {}
		_VectorMove("Vector Move", Vector) = (0.1,0,0,0)
		_DistortionAmount("Distortion Amount", Range( 0 , 1)) = 0.6429809
		_DistortionMask("DistortionMask", 2D) = "white" {}
		_FlowSpeed("FlowSpeed", Range( 0 , 1)) = 0
		_RotColor("RotColor", Color) = (0,0,0,0)
		_TexFondo("TexFondo", 2D) = "white" {}
		_RotSpeed("RotSpeed", Range( 0 , 10)) = 0
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
			uniform sampler2D _Texture2;
			uniform sampler2D _Texture1;
			uniform float4 _Texture1_ST;
			uniform float _FlowSpeed;
			uniform sampler2D _RotateTex;
			uniform float4 _RotScale;
			uniform float _RotSpeed;
			uniform sampler2D _DistortionMask;
			uniform float4 _RotColor;
			uniform sampler2D _TexFondo;
			uniform sampler2D _Texture0;
			uniform float4 _TexFondo_ST;
			uniform float _DistortionAmount;
			uniform float2 _VectorMove;
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

				float2 uv_Texture1 = IN.texcoord.xy * _Texture1_ST.xy + _Texture1_ST.zw;
				float4 tex2DNode14_g4 = tex2D( _Texture1, uv_Texture1 );
				float2 appendResult20_g4 = (float2(tex2DNode14_g4.r , tex2DNode14_g4.g));
				float mulTime44 = _Time.y * _FlowSpeed;
				float TimeVar197_g4 = mulTime44;
				float2 temp_cast_0 = (TimeVar197_g4).xx;
				float2 temp_output_18_0_g4 = ( appendResult20_g4 - temp_cast_0 );
				float4 tex2DNode72_g4 = tex2D( _Texture2, temp_output_18_0_g4 );
				float4 color57 = IsGammaSpace() ? float4(0,1,0.09055519,0) : float4(0,1,0.008619074,0);
				float4 temp_output_57_0_g2 = _RotScale;
				float2 temp_output_2_0_g2 = (temp_output_57_0_g2).zw;
				float2 temp_cast_1 = (1.0).xx;
				float2 temp_output_13_0_g2 = ( ( ( IN.texcoord.xy + (temp_output_57_0_g2).xy ) * temp_output_2_0_g2 ) + -( ( temp_output_2_0_g2 - temp_cast_1 ) * 0.5 ) );
				float mulTime30 = _Time.y * _RotSpeed;
				float TimeVar197_g2 = mulTime30;
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
				float2 temp_output_84_0_g1 = (UnpackScaleNormal( appendResult82_g1, _DistortionAmount )).xy;
				float2 panner179_g1 = ( 1.0 * _Time.y * _VectorMove + MainUvs222_g1);
				float2 temp_output_71_0_g1 = ( temp_output_84_0_g1 + panner179_g1 );
				float4 tex2DNode96_g1 = tex2D( _TexFondo, temp_output_71_0_g1 );
				float2 uv_DistortionMask232_g1 = IN.texcoord.xy;
				float2 uv_Texture = IN.texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
				float4 temp_output_192_0_g1 = tex2D( _Texture, uv_Texture );
				float4 temp_output_192_0_g2 = ( ( tex2DNode96_g1 * tex2DNode96_g1.a * tex2D( _DistortionMask, uv_DistortionMask232_g1 ).g ) + temp_output_192_0_g1 );
				float4 temp_output_192_0_g4 = ( ( ( tex2DNode97_g2 * lerpResult125_g2 * tex2DNode97_g2.a ) * _RotColor ) + temp_output_192_0_g2 );
				
				half4 color = ( ( ( tex2DNode72_g4 * tex2DNode14_g4.a ) * color57 ) + temp_output_192_0_g4 );
				
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
0;551;1507;440;986.4043;-290.526;2.529146;True;False
Node;AmplifyShaderEditor.CommentaryNode;46;-1366.706,-639.5447;Inherit;False;640.2814;284.7804;Sprite;2;3;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-339.1184,499.0336;Inherit;False;546.3201;613.0883;Rotate;5;51;33;38;30;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;49;-1018.338,-271.5669;Inherit;False;358.8051;923.0383;Distortion;5;48;47;21;17;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1316.706,-589.5447;Inherit;True;Property;_Texture;Texture;19;0;Create;True;0;0;0;False;0;False;None;80ab37a9e4f49c842903bb43bdd7bcd2;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;51;-286.3876,995.3325;Inherit;False;Property;_RotSpeed;RotSpeed;18;0;Create;True;0;0;0;False;0;False;0;6.403897;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;48;-957.0975,179.0033;Inherit;False;Property;_VectorMove;Vector Move;12;0;Create;True;0;0;0;False;0;False;0.1,0;0.1,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;21;-952.6919,-16.50646;Inherit;True;Property;_Texture0;Texture 0;11;0;Create;True;0;0;0;False;0;False;None;7c22d29dd2fb52c449a3beef7581f241;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;47;-959.9728,316.4017;Inherit;False;Property;_DistortionAmount;Distortion Amount;13;0;Create;True;0;0;0;False;0;False;0.6429809;0.6429809;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;17;-947.8728,-221.5669;Inherit;True;Property;_TexFondo;TexFondo;17;0;Create;True;0;0;0;False;0;False;None;8088fd32a1778f64b9f14b5af6b3d8c1;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;11;-968.338,421.4714;Inherit;True;Property;_DistortionMask;DistortionMask;14;0;Create;True;0;0;0;False;0;False;None;596678c53fd54a640bf95ba7dfafd092;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;13;-1044.125,-584.7643;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;653.8455,1251.487;Inherit;False;Property;_FlowSpeed;FlowSpeed;15;0;Create;True;0;0;0;False;0;False;0;0.287767;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;1;-282.0059,13.32998;Inherit;False;UI-Sprite Effect Layer;0;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,0,225,0,242,0,237,0,249,0,186,0,177,1,182,0,229,1,92,0,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.Vector4Node;38;-1.275082,806.8202;Inherit;False;Property;_RotScale;RotScale;8;0;Create;True;0;0;0;False;0;False;0,0,1,-5;0,0,1,-5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;55;-289.1184,549.0336;Inherit;False;Property;_RotColor;RotColor;16;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1308194,0.04797081,0.9245283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;33;-282.8033,742.5536;Inherit;True;Property;_RotateTex;RotateTex;9;0;Create;True;0;0;0;False;0;False;None;ffd5bcaa48c1bc04dbc49b46a85b7fe9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleTimeNode;30;8.91155,1001.962;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;43;881.8541,964.6854;Inherit;True;Property;_Texture1;Texture 1;7;0;Create;True;0;0;0;False;0;False;7b0842e3d0da6bf468f08b4a0ad9db9b;7b0842e3d0da6bf468f08b4a0ad9db9b;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;32;478.634,320.4174;Inherit;False;UI-Sprite Effect Layer;0;;2;789bf62641c5cfe4ab7126850acc22b8;18,74,2,204,2,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,0,98,1,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TexturePropertyNode;42;886.2997,754.7344;Inherit;True;Property;_Texture2;Texture 2;10;0;Create;True;0;0;0;False;0;False;131633c45b26caa4f9673a16077a1970;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;57;873.1088,530.8897;Inherit;False;Constant;_Color0;Color 0;16;0;Create;True;0;0;0;False;0;False;0,1,0.09055519,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;44;970.8204,1252.337;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;45;1454.763,322.9977;Inherit;False;UI-Sprite Effect Layer;0;;4;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1898.358,315.7236;Float;False;True;-1;2;ASEMaterialInspector;0;4;UICombine;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;13;0;3;0
WireConnection;1;192;13;0
WireConnection;1;37;17;0
WireConnection;1;181;48;0
WireConnection;1;75;21;0
WireConnection;1;80;47;0
WireConnection;1;233;11;0
WireConnection;30;0;51;0
WireConnection;32;192;1;0
WireConnection;32;39;55;0
WireConnection;32;37;33;0
WireConnection;32;101;11;0
WireConnection;32;57;38;0
WireConnection;32;40;30;0
WireConnection;44;0;53;0
WireConnection;45;192;32;0
WireConnection;45;39;57;0
WireConnection;45;37;42;0
WireConnection;45;33;43;0
WireConnection;45;40;44;0
WireConnection;0;0;45;0
ASEEND*/
//CHKSM=53D2FAF079CB0959E7B626421937DA425C50038E