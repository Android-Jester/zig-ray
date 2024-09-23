//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const rl = @import("raylib");
const Math = rl.math;
const Camera = rl.Camera;
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn cameraYaw(camera: *Camera, angle: f32, rotateAroundTarget: bool) void {
    const up: rl.Vector3 = getCameraUp(camera);
    var targetPosition = Math.vector3Subtract(camera.target, camera.position);
    targetPosition = Math.vector3RotateByAxisAngle(targetPosition, up, angle);
    if (rotateAroundTarget) {
        // Move position relative to target
        camera.position = Math.vector3Subtract(camera.target, targetPosition);
    } else // rotate around camera.position
    {
        // Move target relative to position
        camera.target = Math.vector3Add(camera.position, targetPosition);
    }
}

pub fn cameraPitch(camera: *Camera, angle: f32, lockView: bool, rotateAroundTarget: bool, rotateUp: bool) void {
    const up = getCameraUp(camera);
    var angletemp = angle;

    // View vector
    var targetPosition = Math.vector3Subtract(camera.target, camera.position);

    if (lockView) {
        // In these camera modes we clamp the Pitch angle
        // to allow only viewing straight up or down.

        // Clamp view up
        var maxAngleUp: f32 = Math.vector3Angle(up, targetPosition);
        maxAngleUp -= 0.001; // avoid numerical errors
        if (angle > maxAngleUp) angletemp = maxAngleUp;

        // Clamp view down
        var maxAngleDown = Math.vector3Angle(Math.vector3Negate(up), targetPosition);
        maxAngleDown *= -1.0; // downwards angle is negative
        maxAngleDown += 0.001; // avoid numerical errors
        if (angle < maxAngleDown) angletemp = maxAngleDown;
    }

    // // Rotation axis
    const right = getCameraRight(camera);

    // // Rotate view vector around right axis
    targetPosition = Math.vector3RotateByAxisAngle(targetPosition, right, angletemp);

    if (rotateAroundTarget) {
        // Move position relative to target
        camera.position = Math.vector3Subtract(camera.target, targetPosition);
    } else // rotate around camera.position
    {
        // Move target relative to position
        camera.target = Math.vector3Add(camera.position, targetPosition);
    }

    if (rotateUp) {
        // Rotate up direction around right axis
        camera.up = Math.vector3RotateByAxisAngle(camera.up, right, angletemp);
    }
}

pub fn getCameraUp(camera: *Camera) rl.Vector3 {
    return Math.vector3Normalize(camera.*.up);
}

fn getCameraRight(camera: *Camera) rl.Vector3 {
    const forward = getCameraForward(camera);
    const up = getCameraUp(camera);

    return Math.vector3Normalize(Math.vector3CrossProduct(forward, up));
}

fn getCameraForward(camera: *Camera) rl.Vector3 {
    return Math.vector3Normalize(Math.vector3Subtract(camera.target, camera.position));
}
