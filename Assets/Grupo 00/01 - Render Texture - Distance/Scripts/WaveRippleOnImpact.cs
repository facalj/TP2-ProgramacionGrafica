using UnityEngine;

public class RippleOnImpact : MonoBehaviour
{
    public Renderer targetRenderer;
    public float rippleSpeed = 5f;
    public float rippleFrequency = 10f;
    public float rippleAmplitude = 0.2f;

    private MaterialPropertyBlock propBlock;
    private int originID, speedID, freqID, ampID, startTimeID;

    void Start()
    {
        propBlock = new MaterialPropertyBlock();

        originID = Shader.PropertyToID("_RippleOrigin");
        speedID = Shader.PropertyToID("_RippleSpeed");
        freqID = Shader.PropertyToID("_RippleFrequency");
        ampID = Shader.PropertyToID("_RippleAmplitude");
        startTimeID = Shader.PropertyToID("_RippleStartTime");
    }

    void OnCollisionEnter(Collision collision)
    {
        // Punto de impacto
        Vector3 hitPoint = collision.contacts[0].point;
        Debug.Log($"{collision.gameObject.name} {hitPoint}");
        
        targetRenderer.GetPropertyBlock(propBlock);
        
        propBlock.SetVector(originID, hitPoint);
        propBlock.SetFloat(speedID, rippleSpeed);
        propBlock.SetFloat(freqID, rippleFrequency);
        propBlock.SetFloat(ampID, rippleAmplitude);
        propBlock.SetFloat(startTimeID, Time.time);
        
        targetRenderer.SetPropertyBlock(propBlock);
    }
}