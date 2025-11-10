using System;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Material", menuName = "Material Settings")]
public class MaterialSettingsSO : ScriptableObject
{
    [SerializeField] public Material material;
    [SerializeField] public List<String> floatValues;
}
