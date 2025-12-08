// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_MultiColor"
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
		_Imagen("Imagen", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_Texture0("Texture 0", 2D) = "white" {}
		_Texture1("Texture 1", 2D) = "white" {}
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
			uniform sampler2D _Imagen;
			uniform float4 _Imagen_ST;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;
			uniform sampler2D _Texture0;
			uniform sampler2D _Texture1;
			uniform float4 _Texture1_ST;

			
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

				float2 uv_Imagen = IN.texcoord.xy * _Imagen_ST.xy + _Imagen_ST.zw;
				float2 texCoord47_g2 = IN.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 center45_g2 = float2( 0.5,0.5 );
				float2 delta6_g2 = ( texCoord47_g2 - center45_g2 );
				float angle10_g2 = ( length( delta6_g2 ) * 150.0 );
				float x23_g2 = ( ( cos( angle10_g2 ) * delta6_g2.x ) - ( sin( angle10_g2 ) * delta6_g2.y ) );
				float2 break40_g2 = center45_g2;
				float2 texCoord39 = IN.texcoord.xy * float2( 0,0 ) + float2( 0,0 );
				float2 panner41 = ( _SinTime.w * float2( 0.1,0.1 ) + texCoord39);
				float2 break41_g2 = panner41;
				float y35_g2 = ( ( sin( angle10_g2 ) * delta6_g2.x ) + ( cos( angle10_g2 ) * delta6_g2.y ) );
				float2 appendResult44_g2 = (float2(( x23_g2 + break40_g2.x + break41_g2.x ) , ( break40_g2.y + break41_g2.y + y35_g2 )));
				float2 uv_Mask = IN.texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
				float2 uv_Texture1 = IN.texcoord.xy * _Texture1_ST.xy + _Texture1_ST.zw;
				float4 tex2DNode14_g1 = tex2D( _Texture1, uv_Texture1 );
				float2 appendResult20_g1 = (float2(tex2DNode14_g1.r , tex2DNode14_g1.g));
				float TimeVar197_g1 = _SinTime.w;
				float2 temp_cast_1 = (TimeVar197_g1).xx;
				float2 temp_output_18_0_g1 = ( appendResult20_g1 - temp_cast_1 );
				float4 tex2DNode72_g1 = tex2D( _Texture0, temp_output_18_0_g1 );
				float4 color51 = IsGammaSpace() ? float4(0.1320755,0.1320755,0.1320755,0) : float4(0.01574109,0.01574109,0.01574109,0);
				float4 temp_output_192_0_g1 = color51;
				
				half4 color = ( ( ( tex2D( _Imagen, uv_Imagen ) + float4( ( appendResult44_g2 / 5.0 ), 0.0 , 0.0 ) ) * tex2D( _Mask, uv_Mask ) ) + ( ( ( tex2DNode72_g1 * tex2DNode14_g1.a ) * float4( 0.1509434,0.1509434,0.1509434,1 ) ) + temp_output_192_0_g1 ) );
				
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
1920;23;1920;988;2275.728;1434.539;1.9;True;False
Node;AmplifyShaderEditor.SinTimeNode;57;-1808.329,-0.4440801;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-1828.542,-167.746;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;41;-1443.734,-169.8107;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1430.461,-19.83178;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;150;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;13;-1546.057,-731.4014;Inherit;True;Property;_Imagen;Imagen;0;0;Create;True;0;0;0;False;0;False;None;6b6e7903612e77f4ba1d6a5c407bbad4;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;53;-1144.936,-238.0168;Inherit;True;Twirl;-1;;2;90936742ac32db8449cd21ab6dd337c8;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT;0;False;4;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-832.9719,-65.60903;Inherit;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;71;-637.8551,-236.2277;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;14;-1145.303,-1009.908;Inherit;True;Property;_Mask;Mask;8;0;Create;True;0;0;0;False;0;False;None;55d8d6939f4a8d1459d9e8a23745da0a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;12;-1153.475,-719.3749;Inherit;True;Property;_TextureSample2;Texture Sample 2;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-831.5422,-1010.836;Inherit;True;Property;_TextureSample3;Texture Sample 3;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-332.159,-678.3654;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinTimeNode;45;117.1699,94.42935;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;51;-58.71094,-519.9354;Inherit;False;Constant;_Color0;Color 0;9;0;Create;True;0;0;0;False;0;False;0.1320755,0.1320755,0.1320755,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;50;-92.65648,-121.1026;Inherit;True;Property;_Texture1;Texture 1;10;0;Create;True;0;0;0;False;0;False;None;67024cf7307e4394ba78211aa1573ecb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;48;-106.4404,-335.6262;Inherit;True;Property;_Texture0;Texture 0;9;0;Create;True;0;0;0;False;0;False;None;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;44;336.4783,-341.3334;Inherit;True;UI-Sprite Effect Layer;1;;1;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,1,1,1;False;39;COLOR;0.1509434,0.1509434,0.1509434,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-88.03305,-845.1862;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;701.3126,-799.7805;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1030.424,-792.068;Float;False;True;-1;2;ASEMaterialInspector;0;4;S_MultiColor;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;41;0;39;0
WireConnection;41;1;57;4
WireConnection;53;3;54;0
WireConnection;53;4;41;0
WireConnection;71;0;53;0
WireConnection;71;1;70;0
WireConnection;12;0;13;0
WireConnection;16;0;14;0
WireConnection;10;0;12;0
WireConnection;10;1;71;0
WireConnection;44;192;51;0
WireConnection;44;37;48;0
WireConnection;44;33;50;0
WireConnection;44;40;45;4
WireConnection;17;0;10;0
WireConnection;17;1;16;0
WireConnection;52;0;17;0
WireConnection;52;1;44;0
WireConnection;0;0;52;0
ASEEND*/
//CHKSM=11672F36B20A25A726A3EDD9D5A3E95226F94175