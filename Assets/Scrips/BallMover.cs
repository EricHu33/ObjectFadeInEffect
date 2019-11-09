using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class BallMover : MonoBehaviour
{
    private Rigidbody m_body;
    // Start is called before the first frame update
    void Start()
    {
        m_body = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        var movement = Vector3.zero;
        if (Input.GetKey(KeyCode.W))
        {
            movement += new Vector3(0, 0, 1);
        }
        if (Input.GetKey(KeyCode.S))
        {
            movement += new Vector3(0, 0, -1);
        }
        if (Input.GetKey(KeyCode.D))
        {
            movement += new Vector3(1, 0, 0);
        }
        if (Input.GetKey(KeyCode.A))
        {
            movement += new Vector3(-1, 0, 0);
        }
        m_body.AddForce(movement * 10);

        if (transform.position.y < -10)
        {
            transform.position = new Vector3(0, 8, 5);
        }
    }
}
