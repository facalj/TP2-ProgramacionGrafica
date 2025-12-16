// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "S_Shield2"
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
		_ShieldPatternColor1("Shield Pattern Color", Color) = (0.2470588,0.7764706,0.9098039,1)
		[IntRange]_ShieldPatternSize1("Shield Pattern Size", Range( 1 , 20)) = 5
		_ShieldAnimSpeed1("Shield Anim Speed", Range( -10 , 10)) = 3
		_Texture3("Texture 0", 2D) = "white" {}
		_Texture4("Texture 3", 2D) = "white" {}
		_Texture2("Texture 1", 2D) = "white" {}
		[NoScaleOffset][Normal]_DistortionNormalMap1("Distortion Normal Map", 2D) = "bump" {}
		_Texture1("Texture", 2D) = "white" {}
		[NoScaleOffset]_BlendFireMask1("Blend Fire Mask", 2D) = "white" {}
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
			uniform sampler2D _Texture3;
			uniform sampler2D _Texture2;
			uniform float4 _Texture2_ST;
			uniform sampler2D _Texture1;
			uniform float4 _Texture1_ST;
			uniform sampler2D _Texture4;
			uniform sampler2D _DistortionNormalMap1;
			uniform float _ShieldPatternSize1;
			uniform float _ShieldAnimSpeed1;
			uniform sampler2D _BlendFireMask1;
			uniform float4 _ShieldPatternColor1;

			
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
				float4 tex2DNode72_g585 = tex2D( _Texture3, temp_output_18_0_g585 );
				float2 uv_Texture1 = IN.texcoord.xy * _Texture1_ST.xy + _Texture1_ST.zw;
				float4 temp_output_192_0_g584 = tex2D( _Texture1, uv_Texture1 );
				float2 appendResult9 = (float2(_ShieldPatternSize1 , _ShieldPatternSize1));
				float2 appendResult8 = (float2(0.5 , ( _Time * _ShieldAnimSpeed1 ).x));
				float2 texCoord13 = IN.texcoord.xy * appendResult9 + appendResult8;
				float2 MainUvs222_g584 = texCoord13;
				float4 tex2DNode65_g584 = tex2D( _DistortionNormalMap1, MainUvs222_g584 );
				float4 appendResult82_g584 = (float4(0.0 , tex2DNode65_g584.g , 0.0 , tex2DNode65_g584.r));
				float2 temp_output_84_0_g584 = (UnpackScaleNormal( appendResult82_g584, 0.01 )).xy;
				float2 panner179_g584 = ( 1.0 * _Time.y * float2( 0,0.27 ) + MainUvs222_g584);
				float2 temp_output_71_0_g584 = ( temp_output_84_0_g584 + panner179_g584 );
				float4 tex2DNode96_g584 = tex2D( _Texture4, temp_output_71_0_g584 );
				float2 uv_BlendFireMask1232_g584 = IN.texcoord.xy;
				float4 ShieldPatternColor7 = _ShieldPatternColor1;
				float4 temp_output_192_0_g585 = ( temp_output_192_0_g584 + ( ( ( tex2DNode96_g584 * tex2DNode96_g584.a * tex2D( _BlendFireMask1, uv_BlendFireMask1232_g584 ).g ) * ShieldPatternColor7 ) * (temp_output_192_0_g584).a ) );
				
				half4 color = ( ( ( tex2DNode72_g585 * tex2DNode14_g585.a ) * float4( 0,1,0.03731489,1 ) ) + temp_output_192_0_g585 );
				
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
0;309;1407;682;2074.769;60.52481;1.561556;True;False
Node;AmplifyShaderEditor.RangedFloatNode;1;-3182.566,316.91;Float;False;Property;_ShieldAnimSpeed1;Shield Anim Speed;9;0;Create;True;0;0;0;False;0;False;3;3;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;2;-3108.974,123.7551;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-2925.418,-11.09451;Float;False;Property;_ShieldPatternSize1;Shield Pattern Size;8;1;[IntRange];Create;True;0;0;0;False;0;False;5;2;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;4;-2838.277,107.0485;Float;False;Constant;_Vector2;Vector 1;6;0;Create;True;0;0;0;False;0;False;0.5,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-2866.438,247.1689;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;6;-2643.04,-361.9754;Float;False;Property;_ShieldPatternColor1;Shield Pattern Color;7;0;Create;True;0;0;0;False;0;False;0.2470588,0.7764706,0.9098039,1;0.07418585,1,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1793.328,-231.387;Inherit;True;Property;_Texture1;Texture;14;0;Create;True;0;0;0;False;0;False;6b6e7903612e77f4ba1d6a5c407bbad4;6b6e7903612e77f4ba1d6a5c407bbad4;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-2330.14,-361.5754;Float;False;ShieldPatternColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;8;-2559.678,221.6475;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;9;-2585.418,12.90549;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;14;-1582.021,733.6313;Float;True;Property;_BlendFireMask1;Blend Fire Mask;15;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;55d8d6939f4a8d1459d9e8a23745da0a;27417a908e222e541a8392d922b67986;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;17;-1983.773,489.4371;Float;True;Property;_DistortionNormalMap1;Distortion Normal Map;13;2;[NoScaleOffset];[Normal];Create;True;0;0;0;False;0;False;dd2fd2df93418444c8e280f1d34deeb5;11f03d9db1a617e40b7ece71f0a84f6f;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;15;-1996.142,55.52799;Inherit;False;7;ShieldPatternColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;12;-1962.177,693.3408;Float;False;Constant;_Vector3;Vector 2;27;0;Create;True;0;0;0;False;0;False;0,0.27;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;11;-2001.326,273.3542;Inherit;True;Property;_Texture4;Texture 3;11;0;Create;True;0;0;0;False;0;False;None;61c0b9c0523734e0e91bc6043c72a490;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-2375.775,153.9474;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-1532.733,-227.336;Inherit;True;Property;_TextureSample1;Texture Sample 0;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;21;-1084.137,83.63789;Inherit;True;UI-Sprite Effect Layer;0;;584;789bf62641c5cfe4ab7126850acc22b8;18,74,0,204,0,191,1,225,1,242,0,237,0,249,0,186,0,177,1,182,0,229,1,92,1,98,1,234,0,126,0,129,0,130,0,31,2;18;192;COLOR;1,1,1,1;False;39;COLOR;1,1,1,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;0.01;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TexturePropertyNode;19;-702.6516,504.6218;Inherit;True;Property;_Texture2;Texture 1;12;0;Create;True;0;0;0;False;0;False;67024cf7307e4394ba78211aa1573ecb;67024cf7307e4394ba78211aa1573ecb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SinTimeNode;18;-671.4059,757.7499;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;20;-716.4355,290.0981;Inherit;True;Property;_Texture3;Texture 0;10;0;Create;True;0;0;0;False;0;False;131633c45b26caa4f9673a16077a1970;131633c45b26caa4f9673a16077a1970;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;22;-412.7945,94.86336;Inherit;True;UI-Sprite Effect Layer;0;;585;789bf62641c5cfe4ab7126850acc22b8;18,74,1,204,1,191,1,225,0,242,0,237,0,249,0,186,0,177,0,182,0,229,0,92,1,98,0,234,0,126,0,129,1,130,0,31,1;18;192;COLOR;1,0.0990566,0.0990566,1;False;39;COLOR;0,1,0.03731489,1;False;37;SAMPLER2D;;False;218;FLOAT2;0,0;False;239;FLOAT2;0,0;False;181;FLOAT2;0,0;False;75;SAMPLER2D;;False;80;FLOAT;1;False;183;FLOAT2;0,0;False;188;SAMPLER2D;;False;33;SAMPLER2D;;False;248;FLOAT2;0,0;False;233;SAMPLER2D;;False;101;SAMPLER2D;;False;57;FLOAT4;0,0,0,0;False;40;FLOAT;0;False;231;FLOAT;1;False;30;FLOAT;1;False;2;COLOR;0;FLOAT2;172
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;4;S_Shield2;5056123faa0c79b47ab6ad7e8bf059a4;True;Default;0;0;Default;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;True;True;True;True;True;0;True;-9;False;False;False;False;False;False;False;True;True;0;True;-5;255;True;-8;255;True;-7;0;True;-4;0;True;-6;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;0;True;-11;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;5;0;2;0
WireConnection;5;1;1;0
WireConnection;7;0;6;0
WireConnection;8;0;4;1
WireConnection;8;1;5;0
WireConnection;9;0;3;0
WireConnection;9;1;3;0
WireConnection;13;0;9;0
WireConnection;13;1;8;0
WireConnection;16;0;10;0
WireConnection;21;192;16;0
WireConnection;21;39;15;0
WireConnection;21;37;11;0
WireConnection;21;218;13;0
WireConnection;21;181;12;0
WireConnection;21;75;17;0
WireConnection;21;233;14;0
WireConnection;22;192;21;0
WireConnection;22;37;20;0
WireConnection;22;33;19;0
WireConnection;22;40;18;4
WireConnection;0;0;22;0
ASEEND*/
//CHKSM=3E33572146E3B27A3E5DE4DA161EA809263FD676