// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Caustic"
{
	Properties
	{
		_Texture0("Texture 0", 2D) = "white" {}
		_TilingBaseMultiply("TilingBaseMultiply", Range( 1 , 2)) = 1
		_TextureTiling("Texture Tiling", Range( 1 , 10)) = 1
		_PanSpeed("PanSpeed", Range( 0 , 14)) = 0
		_PanDir("PanDir", Vector) = (0,0,0,0)
		_Brightness("Brightness", Range( 0 , 1)) = 1
		_FlowMap("FlowMap", 2D) = "white" {}
		_Tiling("Tiling", Vector) = (0.2,0.2,0,0)
		_DistortionWeight("DistortionWeight", Range( 0 , 1)) = 0
		_WaterColor("WaterColor", Color) = (0,0.7903076,0.9622642,0)

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcColor One
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
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
			uniform float _Brightness;
			uniform float2 _Tiling;
			uniform float _TilingBaseMultiply;
			uniform float4 _WaterColor;
			inline float4 TriplanarSampling37( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
			{
				float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
				projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
				float3 nsign = sign( worldNormal );
				half4 xNorm; half4 yNorm; half4 zNorm;
				xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
				yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
				zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
				return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				o.ase_texcoord2.w = 0;
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
				float2 texCoord55 = i.ase_texcoord1.xy * temp_cast_0 + float2( 0,0 );
				float4 tex2DNode56 = tex2D( _FlowMap, texCoord55 );
				float2 appendResult58 = (float2(tex2DNode56.r , tex2DNode56.g));
				float2 lerpResult63 = lerp( texCoord55 , ( appendResult58 + texCoord55 ) , _DistortionWeight);
				float2 panner66 = ( 1.0 * _Time.y * ( _PanDir * _PanSpeed ) + lerpResult63);
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float4 triplanar37 = TriplanarSampling37( _Texture0, WorldPosition, ase_worldNormal, 1.0, ( _Tiling * ( _TilingBaseMultiply * (1.0 + (_SinTime.x - -1.0) * (1.5 - 1.0) / (1.0 - -1.0)) ) ), 1.0, 0 );
				
				
				finalColor = ( ( tex2D( _Texture0, panner66 ) * _Brightness ) + ( triplanar37 * _Brightness ) + _WaterColor );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
363;73;1100;535;4003.176;1173.68;2.495425;True;False
Node;AmplifyShaderEditor.RangedFloatNode;54;-2975.239,-1127.634;Inherit;False;Property;_TextureTiling;Texture Tiling;3;0;Create;True;0;0;0;False;0;False;1;4;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;55;-2477.352,-1157.25;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;56;-1707.971,-1364.068;Inherit;True;Property;_FlowMap;FlowMap;9;0;Create;True;0;0;0;False;0;False;-1;None;958b03790b2d5cf45b0b0c47e95141e3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinTimeNode;48;-1386.113,171.111;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;57;-2097.453,-992.6007;Inherit;False;589.8474;283.5556;Movimiento;3;64;61;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;58;-1378.92,-1252.913;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-1213.428,-1182.131;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;61;-1995.754,-942.6014;Inherit;False;Property;_PanDir;PanDir;7;0;Create;True;0;0;0;False;0;False;0,0;-0.5,-0.55;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;62;-1409.998,-1038.023;Inherit;False;Property;_DistortionWeight;DistortionWeight;11;0;Create;True;0;0;0;False;0;False;0;0.117;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;69;-1163.063,155.0222;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-2034.814,-807.2059;Inherit;False;Property;_PanSpeed;PanSpeed;5;0;Create;True;0;0;0;False;0;False;0;0.25;0;14;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1257.458,56.89674;Float;False;Property;_TilingBaseMultiply;TilingBaseMultiply;2;0;Create;True;0;0;0;False;0;False;1;0.15;1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-946.0731,126.5581;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;-1076.71,-1122.744;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1675.147,-903.2816;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;36;-963.0287,-7.652061;Inherit;False;Property;_Tiling;Tiling;10;0;Create;True;0;0;0;False;0;False;0.2,0.2;0.2,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-756.5246,110.6926;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;24;-1408.319,-512.0143;Inherit;True;Property;_Texture0;Texture 0;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;66;-939.6448,-945.5842;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;67;-629.5535,-925.1279;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;37;-497.36,109.037;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;0;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-336.0649,9.635324;Inherit;False;Property;_Brightness;Brightness;8;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;52;-74.82401,207.5191;Inherit;False;Property;_WaterColor;WaterColor;13;0;Create;True;0;0;0;False;0;False;0,0.7903076,0.9622642,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-8.35265,73.52894;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-8.352551,-52.19747;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2096.365,-130.1425;Inherit;False;Property;_Speed;Speed;4;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;89;-3596.742,-784.7775;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-2093.103,-201.8531;Inherit;False;Property;_TextureRotation;TextureRotation;6;0;Create;True;0;0;0;False;0;False;90;90;0;180;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;92;-3159.076,-807.6949;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-3288.349,-843.3285;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;-2763.36,-792.5621;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;65;-1002.999,-1368.857;Inherit;True;Property;_Texture2;Texture 2;1;0;Create;True;0;0;0;False;0;False;None;dae1f5ea1a06a984c9364c039e91a795;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-2466.902,-432.6278;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;45;-2389.954,-253.062;Inherit;False;Property;_PannerSpeed;PannerSpeed;12;0;Create;True;0;0;0;False;0;False;4.36,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;23;-1906.151,-526.6044;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;90;-3565.68,-864.6865;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;197.7565,30.24615;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;28;-2179.115,-403.1798;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;87;-3003.177,-802.4765;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;86;814.0358,19.20399;Float;False;True;-1;2;ASEMaterialInspector;100;1;Caustic;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;True;1;3;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;False;0
WireConnection;55;0;54;0
WireConnection;56;1;55;0
WireConnection;58;0;56;1
WireConnection;58;1;56;2
WireConnection;59;0;58;0
WireConnection;59;1;55;0
WireConnection;69;0;48;1
WireConnection;46;0;25;0
WireConnection;46;1;69;0
WireConnection;63;0;55;0
WireConnection;63;1;59;0
WireConnection;63;2;62;0
WireConnection;64;0;61;0
WireConnection;64;1;60;0
WireConnection;44;0;36;0
WireConnection;44;1;46;0
WireConnection;66;0;63;0
WireConnection;66;2;64;0
WireConnection;67;0;24;0
WireConnection;67;1;66;0
WireConnection;37;0;24;0
WireConnection;37;3;44;0
WireConnection;40;0;37;0
WireConnection;40;1;38;0
WireConnection;39;0;67;0
WireConnection;39;1;38;0
WireConnection;92;0;91;0
WireConnection;91;0;90;0
WireConnection;91;1;89;0
WireConnection;88;0;87;0
WireConnection;88;1;92;3
WireConnection;23;0;24;0
WireConnection;23;1;28;0
WireConnection;41;0;39;0
WireConnection;41;1;40;0
WireConnection;41;2;52;0
WireConnection;28;0;29;0
WireConnection;28;2;45;0
WireConnection;87;0;92;0
WireConnection;87;1;92;1
WireConnection;86;0;41;0
ASEEND*/
//CHKSM=95FDE4908544D06BBBF045804F82145EF2656720