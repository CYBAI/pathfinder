// pathfinder/shaders/gles2/ecaa-line.vs.glsl
//
// Copyright (c) 2017 Mozilla Foundation

precision highp float;

uniform mat4 uTransform;
uniform ivec2 uFramebufferSize;
uniform ivec2 uBVertexPositionDimensions;
uniform ivec2 uBVertexPathIDDimensions;
uniform sampler2D uBVertexPosition;
uniform sampler2D uBVertexPathID;
uniform bool uLowerPart;

attribute vec2 aQuadPosition;
attribute vec4 aLineIndices;

varying vec4 vEndpoints;

void main() {
    // Fetch B-vertex positions.
    ivec2 pointIndices = ivec2(unpackUInt32Attribute(aLineIndices.xy),
                               unpackUInt32Attribute(aLineIndices.zw));
    vec2 leftPosition = fetchFloat2Data(uBVertexPosition,
                                        pointIndices.x,
                                        uBVertexPositionDimensions);
    vec2 rightPosition = fetchFloat2Data(uBVertexPosition,
                                         pointIndices.y,
                                         uBVertexPositionDimensions);

    // Transform the points, and compute the position of this vertex.
    vec2 position;
    computeQuadPosition(position,
                        leftPosition,
                        rightPosition,
                        aQuadPosition,
                        uFramebufferSize,
                        uTransform);

    int pathID = fetchUInt16Data(uBVertexPathID, pointIndices.x, uBVertexPathIDDimensions);
    float depth = convertPathIndexToDepthValue(pathID);

    gl_Position = vec4(position, depth, 1.0);
    vEndpoints = vec4(leftPosition, rightPosition);
}