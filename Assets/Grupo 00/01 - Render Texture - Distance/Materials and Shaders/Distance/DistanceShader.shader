// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DistanceFromObject"
{
	Properties
	{
		_Frecuency("Frecuency", Range( 0 , 10)) = 0.25
		_TimeScale("TimeScale", Range( 0 , 10)) = 0.25
		_Amplitude("Amplitude", Range( 0 , 100)) = 10
		_DistanceObject("DistanceObject", Vector) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			half filler;
		};

		uniform float3 _DistanceObject;
		uniform float _Frecuency;
		uniform float _TimeScale;
		uniform float _Amplitude;


		struct Gradient
		{
			int type;
			int colorsLength;
			int alphasLength;
			float4 colors[8];
			float2 alphas[8];
		};


		Gradient NewGradient(int type, int colorsLength, int alphasLength, 
		float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
		float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
		{
			Gradient g;
			g.type = type;
			g.colorsLength = colorsLength;
			g.alphasLength = alphasLength;
			g.colors[ 0 ] = colors0;
			g.colors[ 1 ] = colors1;
			g.colors[ 2 ] = colors2;
			g.colors[ 3 ] = colors3;
			g.colors[ 4 ] = colors4;
			g.colors[ 5 ] = colors5;
			g.colors[ 6 ] = colors6;
			g.colors[ 7 ] = colors7;
			g.alphas[ 0 ] = alphas0;
			g.alphas[ 1 ] = alphas1;
			g.alphas[ 2 ] = alphas2;
			g.alphas[ 3 ] = alphas3;
			g.alphas[ 4 ] = alphas4;
			g.alphas[ 5 ] = alphas5;
			g.alphas[ 6 ] = alphas6;
			g.alphas[ 7 ] = alphas7;
			return g;
		}


		float4 SampleGradient( Gradient gradient, float time )
		{
			float3 color = gradient.colors[0].rgb;
			UNITY_UNROLL
			for (int c = 1; c < 8; c++)
			{
			float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
			color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
			}
			#ifndef UNITY_COLORSPACE_GAMMA
			color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
			#endif
			float alpha = gradient.alphas[0].x;
			UNITY_UNROLL
			for (int a = 1; a < 8; a++)
			{
			float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
			alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
			}
			return float4(color, alpha);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 transform2 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float temp_output_7_0 = ( distance( transform2 , float4( _DistanceObject , 0.0 ) ) * _Frecuency );
			float mulTime4 = _Time.y * _TimeScale;
			float temp_output_8_0 = sin( mulTime4 );
			float temp_output_10_0 = sin( ( temp_output_7_0 + temp_output_8_0 ) );
			v.vertex.xyz += ( ( float3(0,1,0) * temp_output_10_0 ) * _Amplitude );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			Gradient gradient12 = NewGradient( 0, 2, 2, float4( 0.4292453, 0.5233583, 1, 0 ), float4( 1, 0, 0.7245893, 1 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			float4 transform2 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float temp_output_7_0 = ( distance( transform2 , float4( _DistanceObject , 0.0 ) ) * _Frecuency );
			float mulTime4 = _Time.y * _TimeScale;
			float temp_output_8_0 = sin( mulTime4 );
			float temp_output_10_0 = sin( ( temp_output_7_0 + temp_output_8_0 ) );
			o.Albedo = SampleGradient( gradient12, temp_output_10_0 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;482;1507;509;2226.157;192.0889;2.104548;True;False
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;2;-945.1463,-129.8029;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1;-890.204,283.9465;Inherit;False;Property;_TimeScale;TimeScale;1;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;3;-940.0203,57.63028;Inherit;False;Property;_DistanceObject;DistanceObject;3;0;Create;True;0;0;0;False;0;False;0,0,0;58,7.4,64;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DistanceOpNode;5;-631.1105,-46.55447;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;4;-638.6512,431.804;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-735.0288,164.0513;Inherit;False;Property;_Frecuency;Frecuency;0;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-420.9033,68.15674;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;8;-445.1164,261.6404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-241.5325,73.47008;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;11;-217.9348,231.4666;Inherit;False;Constant;_Vector1;Vector 1;0;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SinOpNode;10;-99.49231,100.3805;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;120.8997,145.4938;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GradientNode;12;-267.9084,-37.40297;Inherit;False;0;2;2;0.4292453,0.5233583,1,0;1,0,0.7245893,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;250.3857,356.6238;Inherit;False;Property;_Amplitude;Amplitude;2;0;Create;True;0;0;0;False;0;False;10;10;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;15;43.52203,-109.4107;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;480.1214,248.5299;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;17;-936.0114,-340.6382;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-208.7614,533.0483;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;757.4384,59.20209;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;DistanceFromObject;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;2;0
WireConnection;5;1;3;0
WireConnection;4;0;1;0
WireConnection;7;0;5;0
WireConnection;7;1;6;0
WireConnection;8;0;4;0
WireConnection;18;0;7;0
WireConnection;18;1;8;0
WireConnection;10;0;18;0
WireConnection;13;0;11;0
WireConnection;13;1;10;0
WireConnection;15;0;12;0
WireConnection;15;1;10;0
WireConnection;16;0;13;0
WireConnection;16;1;14;0
WireConnection;9;0;7;0
WireConnection;9;1;8;0
WireConnection;0;0;15;0
WireConnection;0;11;16;0
ASEEND*/
//CHKSM=B1E4B28E7FA8DACB6CF346AE02CD778525D83EE2