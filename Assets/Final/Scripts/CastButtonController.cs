using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class CastButtonController : MonoBehaviour
{
    [Header("UI")]
    [SerializeField] private Button castButton;

    [Header("Animator Param")]
    [SerializeField] private string castBoolName = "Cast";
    [SerializeField] private float castDuration = 1.5f;

    [Header("Debug")]
    [SerializeField] private bool logDebug = true;

    private Animator currentAnimator;
    private int castBoolHash;
    private Coroutine castRoutine;
    private bool isCasting;

    private void Awake()
    {
        if (castButton == null)
            castButton = GetComponent<Button>();

        castBoolHash = Animator.StringToHash(castBoolName);

        if (castButton != null)
        {
            castButton.onClick.RemoveListener(OnCastButtonPressed);
            castButton.onClick.AddListener(OnCastButtonPressed);

            castButton.interactable = false;

            if (logDebug)
                Debug.Log($"[CastButtonController] Awake on '{gameObject.name}'. Listener set. interactable=false (waiting animator).");
        }
        else
        {
            Debug.LogWarning($"[CastButtonController] No Button assigned/found on '{gameObject.name}'.");
        }
    }

    public void SetTargetAnimator(Animator animator)
    {
        currentAnimator = animator;

        if (logDebug)
            Debug.Log($"[CastButtonController] SetTargetAnimator on '{gameObject.name}': {(currentAnimator != null ? currentAnimator.name : "NULL")}");

        if (castButton != null)
            castButton.interactable = currentAnimator != null && !isCasting;
    }

    public void ClearTarget()
    {
        if (logDebug)
            Debug.Log($"[CastButtonController] ClearTarget on '{gameObject.name}'");

        currentAnimator = null;

        if (castRoutine != null)
        {
            StopCoroutine(castRoutine);
            castRoutine = null;
        }

        isCasting = false;

        if (castButton != null)
            castButton.interactable = false;
    }

    public void OnCastButtonPressed()
    {
        if (logDebug)
            Debug.Log($"[CastButtonController] Button pressed on '{gameObject.name}'. currentAnimator={(currentAnimator != null ? currentAnimator.name : "NULL")}");

        if (currentAnimator == null)
            return;

        if (isCasting)
            return;

        if (castRoutine != null)
            StopCoroutine(castRoutine);

        castRoutine = StartCoroutine(CastRoutine());
    }

    private IEnumerator CastRoutine()
    {
        isCasting = true;

        if (castButton != null)
            castButton.interactable = false;

        if (logDebug)
            Debug.Log($"[CastButtonController] SetBool '{castBoolName}' = true on animator '{currentAnimator.name}'");

        currentAnimator.SetBool(castBoolHash, true);

        yield return new WaitForSeconds(castDuration);

        if (currentAnimator != null)
        {
            if (logDebug)
                Debug.Log($"[CastButtonController] SetBool '{castBoolName}' = false on animator '{currentAnimator.name}'");

            currentAnimator.SetBool(castBoolHash, false);
        }

        isCasting = false;

        if (castButton != null)
            castButton.interactable = currentAnimator != null;

        castRoutine = null;
    }
}
