using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class MaterialSlider : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI name;
    [SerializeField] private Slider slider;

    private Material material;
    private string propertyName;

    public void Setup(Material material, string propertyName, float min = 0f, float max = 1f)
    {
        this.material = material;
        this.propertyName = propertyName;

        name.text = propertyName;
        slider.minValue = min;
        slider.maxValue = max;

        if (material.HasProperty(propertyName))
        {
            slider.value = material.GetFloat(propertyName);
        }

        slider.onValueChanged.AddListener(UpdateMaterialValue);
    }

    private void UpdateMaterialValue(float value)
    {
        if (material != null && material.HasProperty(propertyName))
        {
            material.SetFloat(propertyName, value);
        }
    }
}