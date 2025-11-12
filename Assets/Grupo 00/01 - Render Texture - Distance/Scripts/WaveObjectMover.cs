using System.Collections.Generic;
using UnityEngine;

public class WaveManager : MonoBehaviour
{
    [Header("ShaderMat")]
    public Material waveMaterial;

    [Header("AffectedObjects")]
    public List<Transform> affectedObjects = new List<Transform>();

    // CacheID
    private int originID, speedID, freqID, ampID;
    
    private Dictionary<Transform, Vector3> originalPositions = new Dictionary<Transform, Vector3>();

    void Start()
    {
        originID = Shader.PropertyToID("_WaveOriginOffset");
        speedID = Shader.PropertyToID("_WaveSpeed");
        freqID = Shader.PropertyToID("_WaveFrequency");
        ampID = Shader.PropertyToID("_WaveAmplitude");
        foreach (var obj in affectedObjects)
        {
            if (obj != null && !originalPositions.ContainsKey(obj))
                originalPositions[obj] = obj.position;
        }
    }

    void Update()
    {
        if (!waveMaterial) return;

        Vector3 origin = waveMaterial.GetVector(originID);
        float speed = waveMaterial.GetFloat(speedID);
        float freq = waveMaterial.GetFloat(freqID);
        float amp = waveMaterial.GetFloat(ampID);
        
        foreach (var obj in affectedObjects)
        {
            if (obj == null) continue;

            Vector3 startPos = originalPositions[obj];
            float distance = Vector3.Distance(startPos, origin);
            float wave = Mathf.Sin(Time.time * speed - distance * freq) * amp;

            obj.position = new Vector3(startPos.x, startPos.y + wave, startPos.z);
        }
    }
}