// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_Fire"
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
		[NoScaleOffset][Normal]_DistortionNormal("Distortion Normal", 2D) = "bump" {}
		_Texture0("Texture 0", 2D) = "white" {}
		_Fire("Fire", 2D) = "black" {}
		_Texture1("Texture 1", 2D) = "white" {}
		_Texture("Texture", 2D) = "white" {}
		[NoScaleOffset]_BlendFireMask("Blend Fire Mask", 2D) = "white" {}
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
			uniform sampler2D _Texture0;
			uniform sampler2D _Texture1;
			uniform float4 _Texture1_ST;
			uniform sampler2D _Texture;
			uniform float4 _Texture_ST;
			uniform sampler2D _Fire;
			uniform sampler2D _DistortionNormal;
			uniform float4 _Fire_ST;
			uniform sampler2D _BlendFireMask;

			
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
				float4 tex2DNode14_g2 = tex2D( _Texture1, uv_Texture1 );
				float2 appendResult20_g2 = (float2(tex2DNode14_g2.r , tex2DNode14_g2.g));
				float TimeVar197_g2 = _SinTime.w;
				float2 temp_cast_0 = (TimeVar197_g2).xx;
				float2 temp_output_18_0_g2 = ( appendResult20_g2 - temp_cast_0 );
				float4 tex2DNode72_g2 = tex2D( _Texture0, temp_output_18_0_g2 );
				float2 uv_Texture = IN.texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
				float4 temp_output_192_0_g582 = tex2D( _Texture, uv_Texture );
				float2 uv_Fire = IN.texcoord.xy * _Fire_ST.xy + _Fire_ST.zw;
				float2 MainUvs222_g582 = uv_Fire;
				float4 tex2DNode65_g582 = tex2D( _DistortionNormal, MainUvs222_g582 );
				float4 appendResult82_g582 = (float4(0.0 , tex2DNode65_g582.g , 0.0 , tex2DNode65_g582.r));
				float2 temp_output_84_0_g582 = (UnpackScaleNormal( appendResult82_g582, 1.0 )).xy;
				float2 panner179_g582 = ( 1.0 * _Time.y * float2( 0,0.1 ) + MainUvs222_g582);
				float2 temp_output_71_0_g582 = ( temp_output_84_0_g582 + panner179_g582 );
				float4 tex2DNode96_g582 = tex2D( _Fire, temp_output_71_0_g582 );
				float2 uv_BlendFireMask232_g582 = IN.texcoord.xy;
				float4 temp_output_192_0_g2 = ( temp_output_192_0_g582 + ( ( tex2DNode96_g582 * tex2DNode96_g582.a * tex2D( _BlendFireMask, uv_BlendFireMask232_g582 ).g ) * (temp_output_192_0_g582).a ) );
				
				half4 color = ( ( ( tex2DNode72_g2 * tex2DNode14_g2.a ) * float4( 1,0,0.09677887,1 ) ) + temp_output_192_0_g2 );
				
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
0;419;1407;572;1240.998;445.1408;1.759978;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-1439.765,-582.9507;Inherit;False;640.2814;284.7804;Sprite;2;8;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;3;-1389.765,-532.9508;Inherit;True;Property;_Texture;Texture;10;0;Create;True;0;0;0;False;0;False;6b6e7903612e77f4ba1d6a5c407bbad4;6b6e7903612e77f4ba1d6a5c407bbad4;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;8;-1117.184,-528.1704;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;18;-1118.859,-268.1801;Float;True;Property;_Fire;Fire;8;0;Create;True;0;0;0;False;0;False;f7e96904e8667e1439548f0f86389447;f7fb9fbf30ebf1b47991670dfd825383;False;black;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector2Node;20;-1111.642,-63.28499;Float;False;Constant;_Vector0;Vector 0;27;0;Create;True;0;0;0;False;0;False;0,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;17;-1136.613,98.39143;Float;True;Property;_BlendFireMask;Blend Fire Mask;11;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;55d8d6939f4a8d1459d9e8a23745da0a;27417a908e222e541a8392d922b67986;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;22;-482.0557,-148.778;Inherit;True;UI-Sprite Effect Layer;0;;582;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,0,225,0,242,0,237,0,249,0,186,0,177,1,182,0,229,1,92,1,98,1,234,0,126,0,129,0,130,0,31,2;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TexturePropertyNode;13;485.88,292.9611;Inherit;True;Property;_Texture1;Texture 1;9;0;Create;True;0;0;0;False;0;False;67024cf7307e4394ba78211aa1573ecb;67024cf7307e4394ba78211aa1573ecb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;14;472.0961,78.43755;Inherit;True;Property;_Texture0;Texture 0;7;0;Create;True;0;0;0;False;0;False;131633c45b26caa4f9673a16077a1970;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SinTimeNode;11;517.1257,546.0892;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;15;760.7787,-143.123;Inherit;True;UI-Sprite Effect Layer;0;;2;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,0.0990566,0.0990566,1;False;39;COLOR;1,0,0.09677887,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1162.636,-139.9969;Float;False;True;-1;2;ASEMaterialInspector;0;4;S_Fire;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;8;0;3;0
WireConnection;22;192;8;0
WireConnection;22;37;18;0
WireConnection;22;181;20;0
WireConnection;22;233;17;0
WireConnection;15;192;22;0
WireConnection;15;37;14;0
WireConnection;15;33;13;0
WireConnection;15;40;11;4
WireConnection;0;0;15;0
ASEEND*/
//CHKSM=6A7D5CA89D012F9080F5BBBB437987680F3FAFB3