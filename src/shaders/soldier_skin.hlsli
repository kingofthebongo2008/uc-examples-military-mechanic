#ifndef __transform_skinned_hlsli__
#define __transform_skinned_hlsli__

#include "dual_quaternion.hlsli"

#define SKIN_LBS

//todo: replace with quaternions
float4 skin_position(float4 position, float4x4 joint_transform, float weight)
{
    return mul( position, joint_transform) * weight;
}

//todo: rework
float3 skin_normal(float3 normal, float4x4 joint_transform, float weight)
{
    return ( mul( float4(normal, 0.0), joint_transform ) * weight ).xyz;
}

float4 skin_position1(float4 position, float4 weights, float4 indices, float4x4 joints[127])
{
    float4 skinned_position = position;

    skinned_position =  skin_position(position, joints[indices.x], weights.x);
    skinned_position += skin_position(position, joints[indices.y], weights.y);
    skinned_position += skin_position(position, joints[indices.z], weights.z);
    skinned_position += skin_position(position, joints[indices.w], weights.w);

    skinned_position /= (weights.x + weights.y + weights.z + weights.w);

    return skinned_position;
}

float3 skin_normal(float3 normal, float4 weights, float4 indices, float4x4 joints[127])
{
    float3 skinned_normal = normal;

    skinned_normal =  skin_normal(normal, joints[indices.x], weights.x);
    skinned_normal += skin_normal(normal, joints[indices.y], weights.y);
    skinned_normal += skin_normal(normal, joints[indices.z], weights.z);
    skinned_normal += skin_normal(normal, joints[indices.w], weights.w);

    skinned_normal /= (weights.x + weights.y + weights.z + weights.w);

    return skinned_normal;
}

void decompose( float4x4 joint, out float3x3 rotation, out float3 translation)
{
    translation.x   = joint._14;
    translation.y   = joint._24;
    translation.z   = joint._34;

    rotation._11    = joint._11;
    rotation._12    = joint._12;
    rotation._13    = joint._13;

    rotation._21    = joint._21;
    rotation._22    = joint._22;
    rotation._23    = joint._23;

    rotation._31    = joint._31;
    rotation._32    = joint._32;
    rotation._33    = joint._33;
}

float4 skin_position2(float4 position, float4 weights, float4 indices, float4x4 joints[127])
{
    float3x3    rotation0;
    float3x3    rotation1;
    float3x3    rotation2;
    float3x3    rotation3;

        float3      translation0;
    float3      translation1;
    float3      translation2;
    float3      translation3;

    //Per bone, can go in a compute pass
    decompose( joints[indices.x], rotation0, translation0);
    decompose( joints[indices.y], rotation1, translation1);
    decompose( joints[indices.z], rotation2, translation2);
    decompose( joints[indices.w], rotation3, translation3);

    quaternion  quaternion0 = quat( rotation0);
    quaternion  quaternion1 = quat( rotation1);
    quaternion  quaternion2 = quat( rotation2);
    quaternion  quaternion3 = quat( rotation3);

    dual_quaternion dq0     = dual_quat( quaternion0, translation0);
    dual_quaternion dq1     = dual_quat( quaternion1, translation1);
    dual_quaternion dq2     = dual_quat( quaternion2, translation2);
    dual_quaternion dq3     = dual_quat( quaternion3, translation3);

    //Per vertex

    quaternion pivot          = rotation(dq0);
    dual_quaternion  dq_blend = mul( dq0, weights.x);

    float wy                  = dot( rotation(dq1), pivot) < 0.0f ? -1.0f : 1.0f;
    weights.y                 = weights.y * wy;

    float wz                  = dot( rotation(dq2), pivot) < 0.0f ? -1.0f : 1.0f;
    weights.z                 = weights.z * wz;

    float ww                  = dot( rotation(dq3), pivot) < 0.0f ? -1.0f : 1.0f;
    weights.w                 = weights.w * ww;

    dq_blend                  = add(dq_blend, mul(dq1, weights.y));
    dq_blend                  = add(dq_blend, mul(dq2, weights.z));
    dq_blend                  = add(dq_blend, mul(dq3, weights.w));

    float3 pos                = transformPoint(dq_blend, position.xyz);
    return float4(pos, 1.0);
}



#endif
