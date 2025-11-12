using UnityEngine;
public class ScreenDistortionController : MonoBehaviour
{
    [Header("Reference")]
    public Transform target;
    public Renderer screenRenderer;

    [Header("DistortionParameters")]
    public float maxDistance = 5f;
    public float intensity = 1f;

    private Material screenMaterial;
    private int distortionID;

    void Start()
    {
        screenMaterial = screenRenderer.material;
        distortionID = Shader.PropertyToID("_DistortionAmount0");
    }

    void Update()
    {
        if (target == null || screenMaterial == null) return;
        float dist = Vector3.Distance(target.position, screenRenderer.transform.position);
        float t = Mathf.Clamp01(1f - (dist / maxDistance));
        float distortion = t * intensity;
        
        screenMaterial.SetFloat(distortionID, distortion);
    }
}
