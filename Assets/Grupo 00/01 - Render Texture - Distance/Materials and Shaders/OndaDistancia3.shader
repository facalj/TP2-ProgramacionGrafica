// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "OndaDistancia3"
{
	Properties
	{
		_VectorPosition("VectorPosition", Vector) = (0,0,0,0)
		_Frecuencia("Frecuencia", Float) = 0
		_Amplitud("Amplitud", Float) = 0
		_TimeScale("TimeScale", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
		};

		uniform float3 _VectorPosition;
		uniform float _Frecuencia;
		uniform float _TimeScale;
		uniform float _Amplitud;


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
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float mulTime19 = _Time.y * _TimeScale;
			float temp_output_6_0 = sin( ( ( distance( ase_worldPos , _VectorPosition ) * _Frecuencia ) * sin( mulTime19 ) ) );
			float3 temp_output_12_0 = ( ( float3(0,1,0) * temp_output_6_0 ) * _Amplitud );
			v.vertex.xyz += temp_output_12_0;
			v.vertex.w = 1;
			v.normal = temp_output_12_0;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float mulTime19 = _Time.y * _TimeScale;
			float temp_output_6_0 = sin( ( ( distance( ase_worldPos , _VectorPosition ) * _Frecuencia ) * sin( mulTime19 ) ) );
			float3 temp_output_12_0 = ( ( float3(0,1,0) * temp_output_6_0 ) * _Amplitud );
			o.Normal = temp_output_12_0;
			Gradient gradient31 = NewGradient( 0, 8, 2, float4( 1, 0, 0, 0 ), float4( 0.972549, 0.5026035, 0, 0.1588312 ), float4( 0.9725245, 1, 0, 0.2911727 ), float4( 0, 1, 0.8494306, 0.4500038 ), float4( 0, 0.9547768, 1, 0.5823606 ), float4( 0, 1, 0.1172209, 0.7088273 ), float4( 0, 1, 0.1180556, 0.8470588 ), float4( 0, 0.5011803, 0.6226415, 1 ), float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
			o.Albedo = SampleGradient( gradient31, temp_output_6_0 ).rgb;
			o.Emission = temp_output_12_0;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
361;73;1103;535;2293.198;643.7002;1.854971;True;False
Node;AmplifyShaderEditor.RangedFloatNode;20;-1615.49,442.5432;Inherit;False;Property;_TimeScale;TimeScale;4;0;Create;True;0;0;0;False;0;False;0;0.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;2;-1689.751,82.30614;Inherit;False;Property;_VectorPosition;VectorPosition;0;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;30;-1693.842,-394.9055;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1418.198,421.9209;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;3;-1319.757,-41.77153;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1434.679,166.5099;Inherit;False;Property;_Frecuencia;Frecuencia;2;0;Create;True;0;0;0;False;0;False;0;1.78;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1171.696,63.83578;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;29;-1208.453,421.5158;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-969.5924,148.5305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;6;-810.5773,137.7013;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;23;-761.529,-171.9736;Inherit;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-511.8461,188.5262;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-553.2555,334.0147;Inherit;False;Property;_Amplitud;Amplitud;3;0;Create;True;0;0;0;False;0;False;0;0.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;31;-471.1897,-721.415;Inherit;False;0;8;2;1,0,0,0;0.972549,0.5026035,0,0.1588312;0.9725245,1,0,0.2911727;0,1,0.8494306,0.4500038;0,0.9547768,1,0.5823606;0,1,0.1172209,0.7088273;0,1,0.1180556,0.8470588;0,0.5011803,0.6226415,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.TransformPositionNode;35;-1691.568,-556.7334;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-335.9555,236.0507;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleRemainderNode;26;-1231.333,568.5383;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-574.8555,-613.865;Inherit;False;Property;_Color0;Color 0;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;1;-1694.961,-249.3833;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GradientSampleNode;33;-284.9721,-578.1408;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;24;-593.9936,-404.7377;Inherit;False;Property;_Color1;Color 1;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;25;-294.9659,-200.7133;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;OndaDistancia3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;19;0;20;0
WireConnection;3;0;30;0
WireConnection;3;1;2;0
WireConnection;10;0;3;0
WireConnection;10;1;11;0
WireConnection;29;0;19;0
WireConnection;27;0;10;0
WireConnection;27;1;29;0
WireConnection;6;0;27;0
WireConnection;22;0;23;0
WireConnection;22;1;6;0
WireConnection;12;0;22;0
WireConnection;12;1;13;0
WireConnection;26;0;19;0
WireConnection;26;1;20;0
WireConnection;33;0;31;0
WireConnection;33;1;6;0
WireConnection;25;0;9;0
WireConnection;25;1;24;0
WireConnection;25;2;6;0
WireConnection;0;0;33;0
WireConnection;0;1;12;0
WireConnection;0;2;12;0
WireConnection;0;11;12;0
WireConnection;0;12;12;0
ASEEND*/
//CHKSM=D3F4A68C890F3158E0561CCC1433B8138348A141