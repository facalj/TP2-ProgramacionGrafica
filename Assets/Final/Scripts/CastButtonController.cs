using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class CastButtonController : MonoBehaviour
{
    [Header("UI")]
    [SerializeField] private Button castButton;

    [Header("Animator")]
    [SerializeField] private string castBoolName = "Cast";
    [SerializeField] private float castDuration = 1.5f;

    private Animator currentAnimator;
    private int castBoolHash;
    private Coroutine castRoutine;
    private bool isCasting;

    private void Awake()
    {
        castBoolHash = Animator.StringToHash(castBoolName);

        if (castButton != null)
        {
            castButton.onClick.AddListener(OnCastButtonPressed);
            castButton.interactable = false;
        }
    }

    public void SetTargetAnimator(Animator animator)
    {
        currentAnimator = animator;

        if (castButton != null)
            castButton.interactable = currentAnimator != null && !isCasting;
    }

    public void ClearTarget()
    {
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

        currentAnimator.SetBool(castBoolHash, true);

        yield return new WaitForSeconds(castDuration);

        if (currentAnimator != null)
            currentAnimator.SetBool(castBoolHash, false);

        isCasting = false;

        if (castButton != null)
            castButton.interactable = currentAnimator != null;

        castRoutine = null;
    }
}
