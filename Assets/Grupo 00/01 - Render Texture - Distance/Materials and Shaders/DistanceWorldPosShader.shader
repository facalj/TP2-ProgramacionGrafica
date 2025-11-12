// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Distance"
{
	Properties
	{
		_WaveSpeed("_WaveSpeed", Range( 0 , 5)) = 5
		_WaveFrequency("_WaveFrequency", Range( 0 , 5)) = 5
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
		};

		uniform float _WaveSpeed;
		uniform float _WaveFrequency;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, 1.0);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float mulTime54 = _Time.y * _WaveSpeed;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 temp_output_32_0 = ( sin( ( mulTime54 + ( distance( ase_worldPos , float3(0,1,0) ) * _WaveFrequency ) ) ) * float3(0,1,0) );
			v.vertex.xyz += temp_output_32_0;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color15 = IsGammaSpace() ? float4(1,0.1825107,0,0) : float4(1,0.02791475,0,0);
			float4 color18 = IsGammaSpace() ? float4(0.9320754,0.7013363,0.2444499,0) : float4(0.8523833,0.4498938,0.04868241,0);
			float mulTime54 = _Time.y * _WaveSpeed;
			float3 ase_worldPos = i.worldPos;
			float3 temp_output_32_0 = ( sin( ( mulTime54 + ( distance( ase_worldPos , float3(0,1,0) ) * _WaveFrequency ) ) ) * float3(0,1,0) );
			float4 lerpResult17 = lerp( color15 , color18 , float4( temp_output_32_0 , 0.0 ));
			o.Albedo = lerpResult17.rgb;
			o.Emission = lerpResult17.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
1920;23;1600;816;1341.48;88.29254;1;True;True
Node;AmplifyShaderEditor.Vector3Node;28;-1012.72,342.6697;Inherit;False;Constant;_Vector0;Vector 0;0;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;59;-1016.98,150.2075;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;3;-807.3222,273.0882;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-818.7202,56.72862;Inherit;False;Property;_WaveSpeed;_WaveSpeed;0;0;Create;True;0;0;0;False;0;False;5;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-787.3803,431.7418;Inherit;False;Property;_WaveFrequency;_WaveFrequency;1;0;Create;True;0;0;0;False;0;False;5;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-646.9789,271.5418;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;54;-530.5033,125.7435;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-442.9208,255.9284;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;33;-186.476,414.0062;Inherit;False;Constant;_Vector1;Vector 1;0;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;4;-287.4281,276.4233;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-141.2627,277.6073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;18;-246.1222,-76.01791;Inherit;False;Constant;_Color1;Color 1;0;0;Create;True;0;0;0;False;0;False;0.9320754,0.7013363,0.2444499,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;15;-185.3513,-314.0534;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;0;False;0;False;1,0.1825107,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;17;65.6571,-23.03336;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;13;242.1932,525.5079;Inherit;False;1;0;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;364,4;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;Distance;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;59;0
WireConnection;3;1;28;0
WireConnection;29;0;3;0
WireConnection;29;1;31;0
WireConnection;54;0;56;0
WireConnection;55;0;54;0
WireConnection;55;1;29;0
WireConnection;4;0;55;0
WireConnection;32;0;4;0
WireConnection;32;1;33;0
WireConnection;17;0;15;0
WireConnection;17;1;18;0
WireConnection;17;2;32;0
WireConnection;0;0;17;0
WireConnection;0;2;17;0
WireConnection;0;11;32;0
WireConnection;0;14;13;0
ASEEND*/
//CHKSM=DCEC9CD9687BDEFED683DEA476FDEE7F09846D2C