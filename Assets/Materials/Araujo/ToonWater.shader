// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonWater"
{
	Properties
	{
		_Texture0("Texture 0", 2D) = "white" {}
		_TextureTiling("Texture Tiling", Range( 1 , 10)) = 0
		_PanSpeed("PanSpeed", Range( 0 , 14)) = 0
		_PanDir("PanDir", Vector) = (0,0,0,0)
		_FlowMap("FlowMap", 2D) = "white" {}
		_DistortionWeight("DistortionWeight", Range( 0 , 1)) = 0
		_Bias("Bias", Range( 0.3 , 3)) = 0
		_Scale("Scale", Range( 0.15 , 1)) = 0
		_Pow("Pow", Range( 0.01 , 10)) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _Texture0;
			uniform float2 _PanDir;
			uniform float _PanSpeed;
			uniform float _TextureTiling;
			uniform sampler2D _FlowMap;
			uniform float _DistortionWeight;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float _Bias;
			uniform float _Scale;
			uniform float _Pow;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 temp_cast_0 = (_TextureTiling).xx;
				float2 texCoord10 = i.ase_texcoord1.xy * temp_cast_0 + float2( 0,0 );
				float4 tex2DNode16 = tex2D( _FlowMap, texCoord10 );
				float2 appendResult18 = (float2(tex2DNode16.r , tex2DNode16.g));
				float2 lerpResult20 = lerp( texCoord10 , ( appendResult18 + texCoord10 ) , _DistortionWeight);
				float2 panner9 = ( 1.0 * _Time.y * ( _PanDir * _PanSpeed ) + lerpResult20);
				float4 tex2DNode6 = tex2D( _Texture0, panner9 );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth22 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth22 = abs( ( screenDepth22 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 1.0 ) );
				float temp_output_30_0 = ( 1.0 - saturate( pow( ( ( distanceDepth22 + _Bias ) * _Scale ) , _Pow ) ) );
				float4 temp_output_31_0 = ( tex2DNode6 + temp_output_30_0 );
				
				
				finalColor = saturate( temp_output_31_0 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
0;73;1920;920;3327.36;485.7999;2.119629;False;False
Node;AmplifyShaderEditor.CommentaryNode;61;-2943.895,-315.0496;Inherit;False;1940.347;800.1974;Toon Water;12;16;17;10;11;18;19;20;21;9;8;6;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2895.646,151.3807;Inherit;False;Property;_TextureTiling;Texture Tiling;1;0;Create;True;0;0;0;False;0;False;0;4;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2618.593,-18.0415;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;36;-2423.355,403.0937;Inherit;False;1319.66;484.9301;Depth Fate;9;22;23;24;26;25;27;28;29;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;16;-2402.811,-254.9456;Inherit;True;Property;_FlowMap;FlowMap;4;0;Create;True;0;0;0;False;0;False;-1;None;958b03790b2d5cf45b0b0c47e95141e3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;22;-2373.356,453.0938;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2246.833,664.7478;Inherit;False;Property;_Bias;Bias;6;0;Create;True;0;0;0;False;0;False;0;0.82;0.3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2180.833,148.7174;Inherit;False;589.8474;283.5556;Movimiento;3;13;12;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-2073.76,-143.7911;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2032.05,490.6834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2192.567,767.6844;Inherit;False;Property;_Scale;Scale;7;0;Create;True;0;0;0;False;0;False;0;0.772;0.15;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-1908.268,-73.00858;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2118.194,334.1129;Inherit;False;Property;_PanSpeed;PanSpeed;2;0;Create;True;0;0;0;False;0;False;0;0.25;0;14;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1859.356,487.3705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;14;-2079.134,198.7175;Inherit;False;Property;_PanDir;PanDir;3;0;Create;True;0;0;0;False;0;False;0,0;-0.5,-0.55;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;25;-1773.614,773.6405;Inherit;False;Property;_Pow;Pow;8;0;Create;True;0;0;0;False;0;False;0;3.42;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2104.838,71.09978;Inherit;False;Property;_DistortionWeight;DistortionWeight;5;0;Create;True;0;0;0;False;0;False;0;0.117;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;20;-1749.13,-8.447672;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1758.527,238.0374;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;28;-1676.506,486.9897;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;9;-1523.132,116.9728;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;29;-1493.59,487.2242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;8;-1689.076,-265.0497;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;None;dae1f5ea1a06a984c9364c039e91a795;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;6;-1321.717,-96.54333;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;30;-1294.346,496.9632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;88;-2266.987,847.416;Inherit;False;1166.364;479.6578;Distortion;9;70;82;84;83;87;85;67;69;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-702.3729,200.1268;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-542.5573,828.2398;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-565.9492,630.5802;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-281.9113,1118.414;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-542.4,1094.097;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;95;2.65652,1081.858;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;32;-333.104,276.2144;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-2204.603,1058.879;Inherit;False;Property;_Normal;Normal;10;0;Create;True;0;0;0;False;0;False;0;0.028;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;85;-2216.987,1170.873;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;68;-1931.056,897.4163;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;69;-1621.159,926.4548;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;82;-1743.973,1097.077;Inherit;True;Property;_TextureSample1;Texture Sample 1;9;0;Create;True;0;0;0;False;0;False;-1;None;f53512d44b91e954dae7bf028209df1a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-1439.56,926.6528;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenColorNode;67;-1296.531,920.5196;Inherit;False;Global;_GrabScreen0;Grab Screen 0;10;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-1888.808,1148.48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;17;-1961.872,-245.2268;Inherit;False;True;True;True;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;87;-2032.115,1174.285;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-364.8121,635.6852;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;64;-139.4384,284.4077;Float;False;True;-1;2;ASEMaterialInspector;100;1;ToonWater;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;10;0;11;0
WireConnection;16;1;10;0
WireConnection;18;0;16;1
WireConnection;18;1;16;2
WireConnection;26;0;22;0
WireConnection;26;1;23;0
WireConnection;19;0;18;0
WireConnection;19;1;10;0
WireConnection;27;0;26;0
WireConnection;27;1;24;0
WireConnection;20;0;10;0
WireConnection;20;1;19;0
WireConnection;20;2;21;0
WireConnection;12;0;14;0
WireConnection;12;1;13;0
WireConnection;28;0;27;0
WireConnection;28;1;25;0
WireConnection;9;0;20;0
WireConnection;9;2;12;0
WireConnection;29;0;28;0
WireConnection;6;0;8;0
WireConnection;6;1;9;0
WireConnection;30;0;29;0
WireConnection;31;0;6;0
WireConnection;31;1;30;0
WireConnection;92;0;6;0
WireConnection;92;1;67;0
WireConnection;92;2;30;0
WireConnection;65;0;31;0
WireConnection;65;1;67;0
WireConnection;94;0;93;0
WireConnection;94;1;30;0
WireConnection;93;0;6;0
WireConnection;93;1;67;0
WireConnection;95;0;92;0
WireConnection;32;0;31;0
WireConnection;69;0;68;1
WireConnection;69;1;68;2
WireConnection;82;5;84;0
WireConnection;70;0;69;0
WireConnection;70;1;82;0
WireConnection;67;0;70;0
WireConnection;84;0;83;0
WireConnection;84;1;87;0
WireConnection;17;0;16;0
WireConnection;87;0;85;0
WireConnection;90;0;65;0
WireConnection;90;1;30;0
WireConnection;64;0;32;0
ASEEND*/
//CHKSM=0CACD47A5EADA6CC8D674AF5791490C198B59988