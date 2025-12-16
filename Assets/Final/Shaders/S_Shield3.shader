// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_Shield3"
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
		_speed("speed", Range( 0.1 , 0.5)) = 0.3211765
		_PanSpeed("PanSpeed", Vector) = (1,1,0,0)
		_ShieldPatternColor("Shield Pattern Color", Color) = (0.2470588,0.7764706,0.9098039,1)
		_Texture0("Texture 0", 2D) = "white" {}
		_Texture3("Texture 3", 2D) = "white" {}
		_Texture2("Texture 2", 2D) = "white" {}
		[NoScaleOffset][Normal]_DistortionNormalMap("Distortion Normal Map", 2D) = "bump" {}
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
			uniform sampler2D _Texture2;
			uniform float4 _Texture2_ST;
			uniform sampler2D _Texture;
			uniform float4 _Texture_ST;
			uniform sampler2D _Texture3;
			uniform sampler2D _DistortionNormalMap;
			uniform float _speed;
			uniform float2 _PanSpeed;
			uniform sampler2D _BlendFireMask;
			uniform float4 _ShieldPatternColor;

			
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

				float2 uv_Texture2 = IN.texcoord.xy * _Texture2_ST.xy + _Texture2_ST.zw;
				float4 tex2DNode14_g585 = tex2D( _Texture2, uv_Texture2 );
				float2 appendResult20_g585 = (float2(tex2DNode14_g585.r , tex2DNode14_g585.g));
				float TimeVar197_g585 = _SinTime.w;
				float2 temp_cast_0 = (TimeVar197_g585).xx;
				float2 temp_output_18_0_g585 = ( appendResult20_g585 - temp_cast_0 );
				float4 tex2DNode72_g585 = tex2D( _Texture0, temp_output_18_0_g585 );
				float2 uv_Texture = IN.texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
				float4 tex2DNode16 = tex2D( _Texture, uv_Texture );
				float4 temp_output_192_0_g584 = tex2DNode16;
				float2 temp_cast_1 = (_speed).xx;
				float2 texCoord26 = IN.texcoord.xy * _PanSpeed + float2( 0,0 );
				float2 panner27 = ( _Time.y * temp_cast_1 + texCoord26);
				float2 MainUvs222_g584 = panner27;
				float4 tex2DNode65_g584 = tex2D( _DistortionNormalMap, MainUvs222_g584 );
				float4 appendResult82_g584 = (float4(0.0 , tex2DNode65_g584.g , 0.0 , tex2DNode65_g584.r));
				float2 temp_output_84_0_g584 = (UnpackScaleNormal( appendResult82_g584, 0.01 )).xy;
				float2 panner179_g584 = ( 1.0 * _Time.y * float2( 0,0.27 ) + MainUvs222_g584);
				float2 temp_output_71_0_g584 = ( temp_output_84_0_g584 + panner179_g584 );
				float4 tex2DNode96_g584 = tex2D( _Texture3, temp_output_71_0_g584 );
				float2 uv_BlendFireMask232_g584 = IN.texcoord.xy;
				float4 ShieldPatternColor7 = _ShieldPatternColor;
				float4 temp_output_192_0_g585 = ( temp_output_192_0_g584 + ( ( ( tex2DNode96_g584 * tex2DNode96_g584.a * tex2D( _BlendFireMask, uv_BlendFireMask232_g584 ).g ) * ShieldPatternColor7 ) * (temp_output_192_0_g584).a ) );
				
				half4 color = ( ( ( tex2DNode72_g585 * tex2DNode14_g585.a ) * float4( 0.3038083,0,0.4339623,1 ) ) + temp_output_192_0_g585 );
				
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
0;309;1407;682;3013.877;574.6564;1.415634;True;False
Node;AmplifyShaderEditor.Vector2Node;24;-3093.049,-30.52698;Inherit;False;Property;_PanSpeed;PanSpeed;8;0;Create;True;0;0;0;False;0;False;1,1;7,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;6;-2686.317,-489.5503;Float;False;Property;_ShieldPatternColor;Shield Pattern Color;9;0;Create;True;0;0;0;False;0;False;0.2470588,0.7764706,0.9098039,1;0.6907423,0.2470588,0.9098039,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-2832.786,-11.99579;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-3001.145,144.1719;Inherit;False;Property;_speed;speed;7;0;Create;True;0;0;0;False;0;False;0.3211765;0.378;0.1;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;23;-2786.714,267.9489;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1975.705,-379.7619;Inherit;True;Property;_Texture;Texture;14;0;Create;True;0;0;0;False;0;False;6b6e7903612e77f4ba1d6a5c407bbad4;6b6e7903612e77f4ba1d6a5c407bbad4;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-2373.417,-489.1503;Float;False;ShieldPatternColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;11;-2044.603,145.7794;Inherit;True;Property;_Texture3;Texture 3;11;0;Create;True;0;0;0;False;0;False;None;61c0b9c0523734e0e91bc6043c72a490;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;27;-2518.027,55.7384;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;17;-2027.051,361.8621;Float;True;Property;_DistortionNormalMap;Distortion Normal Map;13;2;[NoScaleOffset];[Normal];Create;True;0;0;0;False;0;False;dd2fd2df93418444c8e280f1d34deeb5;f53512d44b91e954dae7bf028209df1a;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;14;-1625.297,606.0563;Float;True;Property;_BlendFireMask;Blend Fire Mask;15;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;55d8d6939f4a8d1459d9e8a23745da0a;27417a908e222e541a8392d922b67986;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector2Node;12;-2005.454,565.7658;Float;False;Constant;_Vector2;Vector 2;27;0;Create;True;0;0;0;False;0;False;0,0.27;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;16;-1715.109,-375.7109;Inherit;True;Property;_TextureSample1;Texture Sample 1;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;15;-2039.419,-72.04683;Inherit;False;7;ShieldPatternColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SinTimeNode;18;-714.6827,630.1749;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;21;-1127.413,-43.93694;Inherit;True;UI-Sprite Effect Layer;0;;584;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,1,225,1,242,0,237,0,249,0,186,0,177,1,182,0,229,1,92,1,98,1,234,0,126,0,129,0,130,0,31,2;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;0.01;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TexturePropertyNode;20;-759.7124,162.5233;Inherit;True;Property;_Texture0;Texture 0;10;0;Create;True;0;0;0;False;0;False;131633c45b26caa4f9673a16077a1970;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;19;-745.9285,377.0468;Inherit;True;Property;_Texture2;Texture 2;12;0;Create;True;0;0;0;False;0;False;67024cf7307e4394ba78211aa1573ecb;67024cf7307e4394ba78211aa1573ecb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;22;-467.2407,-43.88083;Inherit;True;UI-Sprite Effect Layer;0;;585;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,0.0990566,0.0990566,1;False;39;COLOR;0.3038083,0,0.4339623,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-15,-39;Float;False;True;-1;2;ASEMaterialInspector;0;4;S_Shield3;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;26;0;24;0
WireConnection;7;0;6;0
WireConnection;27;0;26;0
WireConnection;27;2;25;0
WireConnection;27;1;23;0
WireConnection;16;0;10;0
WireConnection;21;192;16;0
WireConnection;21;39;15;0
WireConnection;21;37;11;0
WireConnection;21;218;27;0
WireConnection;21;181;12;0
WireConnection;21;75;17;0
WireConnection;21;233;14;0
WireConnection;22;192;21;0
WireConnection;22;37;20;0
WireConnection;22;33;19;0
WireConnection;22;40;18;4
WireConnection;0;0;22;0
ASEEND*/
//CHKSM=34C42B5FEC25F5EF88BA1699D287211B00D2B15A