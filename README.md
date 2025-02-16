# Unity HDRP CRT Shader

This shader is a fullscreen shader for Unity that attempts to emulate a CRT screen effect.

Tested to work in Unity version 2022.3.57f1.

---

### Installation Instructions

Simply follow the Unity instructions for how to [Install a UPM package from a Git URL](https://docs.unity3d.com/Manual/upm-ui-giturl.html).

---

### Usage

Just throw the `CRT Volumes` prefab from `Packages/CRT Shader/Runtime/Prefabs` into a HDRP scene and the shader will automagically work.

To customize the output of the shader:
1. Create a new material using the `Fullscreen/CRT` preset and modify the material properties to your liking.
2. Set the `Fullscreen Material` property of each volume in the `CRT Volumes` to your new material.