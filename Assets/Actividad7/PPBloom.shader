// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PPBloom"
{
	Properties
	{
		_RT("RT", 2D) = "white" {}
		_Intensity("Intensity", Float) = 5
		_Noise("Noise", Float) = 10
		_Frequency("Frequency", Range( 0 , 9)) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _RT;
		uniform float4 _RT_ST;
		uniform float _Intensity;
		uniform float _Frequency;
		uniform float _Noise;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_RT = i.uv_texcoord * _RT_ST.xy + _RT_ST.zw;
			float4 tex2DNode33 = tex2D( _RT, uv_RT );
			o.Albedo = tex2DNode33.rgb;
			float4 color44 = IsGammaSpace() ? float4(1,0,0,0) : float4(1,0,0,0);
			float4 temp_output_42_0 = ( ( color44 * ( _Intensity * ( tex2DNode33 * i.vertexColor ) ) ) * i.vertexColor.a );
			float simplePerlin2D46 = snoise( uv_RT*_Noise );
			float ifLocalVar65 = 0;
			if( ( _Time.y % 1.0 ) > _Frequency )
				ifLocalVar65 = simplePerlin2D46;
			else if( ( _Time.y % 1.0 ) == _Frequency )
				ifLocalVar65 = 0.0;
			float4 temp_output_45_0 = ( temp_output_42_0 * ifLocalVar65 );
			o.Emission = temp_output_45_0.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
363;73;1101;535;754.2509;358.0298;1.916861;False;False
Node;AmplifyShaderEditor.TexturePropertyNode;30;-1109.13,-42.38108;Inherit;True;Property;_RT;RT;0;0;Create;True;0;0;0;False;0;False;2ba17cf073a14dd44833f986406f2a3c;2ba17cf073a14dd44833f986406f2a3c;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;33;-794.5484,-45.40068;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;38;-709.7599,167.4;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-421.4012,20.86717;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-323.4788,-83.30556;Inherit;False;Property;_Intensity;Intensity;1;0;Create;True;0;0;0;False;0;False;5;4.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-122.7181,-7.053014;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;44;-76.36876,-235.2894;Inherit;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;0;False;0;False;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-706.2367,433.2515;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;48;-44.56344,523.9078;Inherit;False;Property;_Noise;Noise;2;0;Create;True;0;0;0;False;0;False;10;9.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-7.785826,757.7271;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;62;-31.25251,686.7893;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;224.7434,687.8301;Inherit;False;Property;_Frequency;Frequency;3;0;Create;True;0;0;0;False;0;False;2;0.71;0;9;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleRemainderNode;63;277.8813,554.4846;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;46;183.736,438.9439;Inherit;False;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;196.1545,-30.20212;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;67;448.5737,605.1115;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;65;514.9147,338.2394;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;293.5533,119.9192;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;654.301,146.1203;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinTimeNode;59;716.1168,599.4481;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;60;601.5424,695.2579;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;61;916.7209,324.8247;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1201.892,-26.7191;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;PPBloom;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;33;0;30;0
WireConnection;39;0;33;0
WireConnection;39;1;38;0
WireConnection;40;0;43;0
WireConnection;40;1;39;0
WireConnection;47;2;30;0
WireConnection;63;0;62;0
WireConnection;63;1;54;0
WireConnection;46;0;47;0
WireConnection;46;1;48;0
WireConnection;41;0;44;0
WireConnection;41;1;40;0
WireConnection;65;0;63;0
WireConnection;65;1;66;0
WireConnection;65;2;46;0
WireConnection;65;3;67;0
WireConnection;42;0;41;0
WireConnection;42;1;38;4
WireConnection;45;0;42;0
WireConnection;45;1;65;0
WireConnection;60;0;59;4
WireConnection;60;1;54;0
WireConnection;60;2;54;0
WireConnection;61;0;42;0
WireConnection;61;1;45;0
WireConnection;0;0;33;0
WireConnection;0;2;45;0
ASEEND*/
//CHKSM=B2EEAC0170A41A3A185E404F1B2B56C546EE7102