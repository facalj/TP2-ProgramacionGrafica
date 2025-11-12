using UnityEngine;

[RequireComponent(typeof(Camera))]
public class PPCycle : MonoBehaviour
{
    [Header("Asigna 3 materiales de post-efecto")]
    [SerializeField] private Material effect1;
    [SerializeField] private Material effect2;
    [SerializeField] private Material effect3;

    private Material[] effects;
    private int currentEffect = 0;
    private Camera cam;

    void Start()
    {
        cam = GetComponent<Camera>();
        effects = new Material[] { effect1, effect2, effect3 };

        // Validar
        for (int i = 0; i < effects.Length; i++)
        {
            if (effects[i] == null)
                Debug.LogWarning($"Efecto {i + 1} no asignado.");
        }

        // Aplicar efecto inicial
        ApplyEffect(0);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1) || Input.GetKeyDown(KeyCode.Keypad1))
            ApplyEffect(0);
        else if (Input.GetKeyDown(KeyCode.Alpha2) || Input.GetKeyDown(KeyCode.Keypad2))
            ApplyEffect(1);
        else if (Input.GetKeyDown(KeyCode.Alpha3) || Input.GetKeyDown(KeyCode.Keypad3))
            ApplyEffect(2);
    }

    void ApplyEffect(int index)
    {
        if (index < 0 || index >= effects.Length) return;
        if (effects[index] == null) return;

        currentEffect = index;
        Debug.Log($"Efecto aplicado: {effects[index].name}");
    }

    // SE EJECUTA DESPUÉS DE QUE LA CÁMARA RENDERIZA
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (effects[currentEffect] != null)
        {
            // Aplica el material actual como filtro
            Graphics.Blit(source, destination, effects[currentEffect]);
        }
        else
        {
            // Sin efecto  pasa la imagen limpia
            Graphics.Blit(source, destination);
        }
    }
}
