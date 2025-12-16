// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_Bttn"
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
		_Imagen1("Imagen", 2D) = "white" {}
		_PannerSpeed1("PannerSpeed", Range( 0 , 10)) = 0.85
		_BrightTilingX1("BrightTilingX", Range( 0 , 10)) = 1.85
		_Mask1("Mask", 2D) = "white" {}
		_BrightTilingY1("BrightTilingY", Range( 0 , 1)) = 1
		_Brillo1("Brillo", 2D) = "white" {}
		[NoScaleOffset]_Flow2("Flow", 2D) = "white" {}
		[NoScaleOffset]_FlowDirection2("Flow Direction", 2D) = "white" {}
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
			uniform sampler2D _Mask1;
			uniform float4 _Mask1_ST;
			uniform sampler2D _Imagen1;
			uniform float4 _Imagen1_ST;
			uniform sampler2D _Brillo1;
			uniform float _PannerSpeed1;
			uniform float _BrightTilingX1;
			uniform float _BrightTilingY1;
			uniform sampler2D _Flow2;
			uniform sampler2D _FlowDirection2;
			uniform float4 _FlowDirection2_ST;

			
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

				float2 uv_Mask1 = IN.texcoord.xy * _Mask1_ST.xy + _Mask1_ST.zw;
				float2 uv_Imagen1 = IN.texcoord.xy * _Imagen1_ST.xy + _Imagen1_ST.zw;
				float2 appendResult59 = (float2(_PannerSpeed1 , 0.0));
				float2 appendResult57 = (float2(_BrightTilingX1 , _BrightTilingY1));
				float2 texCoord58 = IN.texcoord.xy * appendResult57 + float2( 0,0 );
				float2 panner60 = ( 1.0 * _Time.y * appendResult59 + texCoord58);
				float4 temp_output_192_0_g587 = ( tex2D( _Mask1, uv_Mask1 ) * ( tex2D( _Imagen1, uv_Imagen1 ) + tex2D( _Brillo1, panner60 ) ) );
				float2 uv_FlowDirection2 = IN.texcoord.xy * _FlowDirection2_ST.xy + _FlowDirection2_ST.zw;
				float4 tex2DNode14_g587 = tex2D( _FlowDirection2, uv_FlowDirection2 );
				float2 appendResult20_g587 = (float2(tex2DNode14_g587.r , tex2DNode14_g587.g));
				float TimeVar197_g587 = _SinTime.w;
				float2 temp_cast_0 = (TimeVar197_g587).xx;
				float2 temp_output_18_0_g587 = ( appendResult20_g587 - temp_cast_0 );
				float4 tex2DNode72_g587 = tex2D( _Flow2, temp_output_18_0_g587 );
				
				half4 color = ( temp_output_192_0_g587 + ( ( ( tex2DNode72_g587 * tex2DNode14_g587.a ) * float4(0.4528302,0.05674274,0,1) ) * (temp_output_192_0_g587).a ) );
				
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
1920;23;1920;988;-305.0682;776.2867;1.427817;True;False
Node;AmplifyShaderEditor.RangedFloatNode;55;-546.0544,107.6668;Inherit;False;Property;_BrightTilingY1;BrightTilingY;11;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-547.4495,26.86493;Inherit;False;Property;_BrightTilingX1;BrightTilingX;9;0;Create;True;0;0;0;False;0;False;1.85;1.892857;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;57;-232.5974,72.83833;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-332.6151,234.2045;Inherit;False;Property;_PannerSpeed1;PannerSpeed;8;0;Create;True;0;0;0;False;0;False;0.85;0.8571429;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;58;-34.21338,50.62372;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;59;-1.337402,184.2895;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;60;263.5746,104.1608;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;61;54.42151,-446.7815;Inherit;True;Property;_Imagen1;Imagen;0;0;Create;True;0;0;0;False;0;False;0a60a34ebcd88c84e914f1aaac7a91bf;0e51316407ca51b4db3a6eb090df2a63;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;62;62.6105,-209.3026;Inherit;True;Property;_Brillo1;Brillo;12;0;Create;True;0;0;0;False;0;False;eac6f9b6fcb311f4a9e72fbe47e388d0;cfe7919cdc24b1a4eaaac38bb9cdcca5;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;65;403.3033,-397.655;Inherit;True;Property;_TextureSample3;Texture Sample 2;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;64;496.8816,-43.47748;Inherit;True;Property;_TextureSample2;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;63;232.0756,-688.7881;Inherit;True;Property;_Mask1;Mask;10;0;Create;True;0;0;0;False;0;False;8964fd4100b742147af2cd070f53ca49;024e2d98af687bf4c99e8ea718b45c4f;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;66;549.8364,-668.7164;Inherit;True;Property;_TextureSample4;Texture Sample 3;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;67;842.1196,-227.3455;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;985.0455,-355.4666;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;70;975.0467,16.15815;Float;True;Property;_FlowDirection2;Flow Direction;14;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;fd6c5c05e964dc040bf165764037c73f;7b0842e3d0da6bf468f08b4a0ad9db9b;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;73;975.0467,-175.842;Float;True;Property;_Flow2;Flow;13;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;131633c45b26caa4f9673a16077a1970;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SinTimeNode;71;1149.261,211.1008;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;72;1490.846,156.158;Float;False;Constant;_FlowTint2;Flow Tint;11;0;Create;True;0;0;0;False;0;False;0.4528302,0.05674274,0,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;74;1730.146,-353.8134;Inherit;True;UI-Sprite Effect Layer;1;;587;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,1,234,0,126,0,129,0,130,0,31,2;18;192;COLOR;1,1,1,0;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2143.477,-348.205;Float;False;True;-1;2;ASEMaterialInspector;0;4;S_Bttn;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;58;0;57;0
WireConnection;59;0;69;0
WireConnection;60;0;58;0
WireConnection;60;2;59;0
WireConnection;65;0;61;0
WireConnection;64;0;62;0
WireConnection;64;1;60;0
WireConnection;66;0;63;0
WireConnection;67;0;65;0
WireConnection;67;1;64;0
WireConnection;68;0;66;0
WireConnection;68;1;67;0
WireConnection;74;192;68;0
WireConnection;74;39;72;0
WireConnection;74;37;73;0
WireConnection;74;33;70;0
WireConnection;74;40;71;4
WireConnection;0;0;74;0
ASEEND*/
//CHKSM=49AEB927D010E95C146D403AF0EA8287FCE18717