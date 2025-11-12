using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class FloatUpDown : MonoBehaviour
{
    public float speed = 2f;
    public float amplitude = 0.5f;

    private Rigidbody rb;
    private Vector3 startPos;
    private float offset;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
        rb.useGravity = false; 
        rb.isKinematic = false; 
        startPos = transform.position;
        offset = Random.Range(0f, Mathf.PI * 2f);
    }

    void FixedUpdate()
    {
        float newY = startPos.y + Mathf.Sin(Time.time * speed + offset) * amplitude;
        Vector3 targetPos = new Vector3(startPos.x, newY, startPos.z);
        
        rb.MovePosition(targetPos);
    }
}