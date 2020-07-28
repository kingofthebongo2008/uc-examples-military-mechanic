#ifndef __interop_h__
#define __interop_h__

#if !defined(__cplusplus)
typedef uint uint32_t;
#include "vector_space.hlsli"
#else
#include <uc/math/math.h>
#include <type_traits>
#endif


namespace interop
{
    #if defined(__cplusplus)
    using namespace uc::math;
    #endif

    typedef uint32_t           offset;

    struct frame
    {
        euclidean_transform_3d   m_view;
        projective_transform_3d  m_perspective;
    };

    struct draw_call
    {
        offset                 m_batch;
        offset                 m_start_vertex;

        offset                 m_blend_weights;
        offset                 m_blend_indices;

        offset                 m_position;
        offset                 m_uv;

        offset                 m_normal;
        offset                 m_tangent;

        euclidean_transform_3d m_world;
    };

    struct draw_call_depth
    {
        offset                 m_batch;
        offset                 m_start_vertex;

        offset                 m_blend_weights;
        offset                 m_blend_indices;

        offset                 m_position;
        euclidean_transform_3d m_world;
    };

    #if defined(__cplusplus)
    static_assert(sizeof(draw_call) <= 32 * 4, "64-bit code generation is not supported.");
    static_assert(sizeof(draw_call_depth) <= 32 * 4, "64-bit code generation is not supported.");
    #endif

    struct skinned_draw_constants
    {
        float4x4 m_joints_palette[127];
    };

    struct float4x2
    {
        float4 m_b0;
        float4 m_b1;
    };

    struct skinned_draw_constants_dq
    {
        float4x2 m_joints_palette[127];
    };
}

#endif