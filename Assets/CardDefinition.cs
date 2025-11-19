using UnityEngine;

[CreateAssetMenu(fileName = "CardDefinition", menuName = "Cards/Card Definition")]
public class CardDefinition : ScriptableObject
{
    [Header("Identity")]
    [SerializeField] private string id;
    [SerializeField] private string displayName;

    [TextArea]
    [SerializeField] private string description;

    [Header("Visuals")]
    [SerializeField] private Sprite icon;

    [Header("3D Model")]
    [SerializeField] private GameObject modelPrefab;

    public string Id => id;
    public string DisplayName => displayName;
    public string Description => description;
    public Sprite Icon => icon;
    public GameObject ModelPrefab => modelPrefab;
}
