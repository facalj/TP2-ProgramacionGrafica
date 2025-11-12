using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Scene", menuName = "SceneManagerSettings")]
public class SceneSettingsSO : ScriptableObject
{
    [SerializeField] public List<string> scenes;
}
