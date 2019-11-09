using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Revealer : MonoBehaviour
{
    [SerializeField]
    private float m_radius;
    [SerializeField]
    private float m_popSpeed = 1.0f;

    private Dictionary<int, float> m_progress = new Dictionary<int, float>();

    void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, m_radius);

    }

    void Update()
    {

        Collider[] hitColliders = Physics.OverlapSphere(transform.position, m_radius);
        foreach (var collider in hitColliders)
        {
            if (collider.gameObject == gameObject)
            {
                continue;
            }
            var id = collider.gameObject.GetInstanceID();

            if (!m_progress.ContainsKey(id))
            {
                m_progress.Add(id, 0);
                StartCoroutine(FillPercentageProperty(id, collider.GetComponent<MeshRenderer>()));
            }
        }
    }

    IEnumerator FillPercentageProperty(int id, MeshRenderer renderer)
    {
        var t = 0f;
        var dir = Vector3.Normalize(renderer.transform.position - transform.position);
        while (t < 1.1f)
        {
            var prop = new MaterialPropertyBlock();

            t += Time.deltaTime * m_popSpeed;
            m_progress[id] = Mathf.Lerp(0, 1.1f, t);
            prop.SetFloat("_Percentage", Mathf.Clamp01(t));

            //Let the object roll toward this transform
            Quaternion rotation;
            if (dir.z * dir.z > dir.x * dir.x)
            {
                if (dir.z > 0)
                {
                    rotation = Quaternion.Euler(-360 * Mathf.Clamp01(t - 0.1f), 0, 0);
                }
                else
                {
                    rotation = Quaternion.Euler(360 * Mathf.Clamp01(t - 0.1f), 0, 0);
                }
            }
            else
            {
                if (dir.x > 0)
                {
                    rotation = Quaternion.Euler(0, 0, 360 * Mathf.Clamp01(t - 0.1f));
                }
                else
                {
                    rotation = Quaternion.Euler(0, 0, -360 * Mathf.Clamp01(t - 0.1f));
                }
            }
            Matrix4x4 mat = Matrix4x4.Rotate(rotation);
            prop.SetMatrix("_RotateMatrix", mat);

            renderer.SetPropertyBlock(prop);
            yield return new WaitForEndOfFrame();
        }


    }
}
