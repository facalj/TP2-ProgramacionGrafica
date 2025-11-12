using UnityEngine;

public class RippleTrigger : MonoBehaviour
{
    public Renderer targetRenderer;
    private Material material;

    // Control interno para reiniciar
    private float lastRippleTime = -1f;
    public float rippleCooldown = 0.3f; // segundos entre ripples

    void Start()
    {
        material = targetRenderer.material;
    }

    void OnCollisionEnter(Collision collision)
    {
        if (Time.time - lastRippleTime < rippleCooldown)
            return;

        lastRippleTime = Time.time;
        
        Vector3 hitPoint = collision.contacts[0].point;
        
        material.SetVector("_RippleCenter", hitPoint);
        material.SetFloat("_RippleStartTime", Time.time);
    }
}