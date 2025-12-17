using UnityEngine;

public class ModelCastMaterialController : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Animator animator;
    [SerializeField] private GameObject shieldObject;

    [Header("Animator")]
    [SerializeField] private string castBoolName = "Cast";

    private int castBoolHash;
    private bool lastState;

    private void Awake()
    {
        if (animator == null)
            animator = GetComponent<Animator>();

        castBoolHash = Animator.StringToHash(castBoolName);

        if (shieldObject != null)
            shieldObject.SetActive(false);
    }

    private void Update()
    {
        if (animator == null || shieldObject == null)
            return;

        bool castActive = animator.GetBool(castBoolHash);

        if (castActive == lastState)
            return;

        lastState = castActive;
        shieldObject.SetActive(castActive);
    }
}
