using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class KnightController :  MonoBehaviour 
{
    float speed = 4;
    float rotSpeed = 60;//80
    float rot = 0f;
    float gravity = 8;


    Vector3 moveDir = Vector3.zero;


    CharacterController controller;
    Animator anim;


    // Start is called before the first frame update
    void Start()
    {
        controller = GetComponent<CharacterController>();
        anim = GetComponent<Animator>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (controller.isGrounded)
        {
            if (Input.GetKey(KeyCode.UpArrow))
            {
                anim.SetBool("walk", true);
                moveDir = new Vector3(0, 0, 1);
                moveDir *= speed;
                moveDir = transform.TransformDirection(moveDir);
            }

            if (Input.GetKeyUp(KeyCode.UpArrow))
            {
                anim.SetBool("walk", false);
                moveDir = new Vector3(0, 0, 0);
            }

            if (Input.GetKey(KeyCode.Space))
            {
                anim.SetBool("walk", false);
                moveDir = new Vector3(0, 1, 0);
                moveDir *= (speed + 6);
                moveDir = transform.TransformDirection(moveDir);
            }

            if (Input.GetKeyUp(KeyCode.Space))
            {
                moveDir = new Vector3(0, 0, 0);

            }
        }

        if (!controller.isGrounded)
        {
            if (Input.GetKey(KeyCode.UpArrow))
            {
                anim.SetBool("walk", true);
                moveDir = new Vector3(0, 0, 1);
                moveDir *= speed;
                moveDir = transform.TransformDirection(moveDir);
            }

            if (Input.GetKeyUp(KeyCode.UpArrow))
            {
                anim.SetBool("walk", false);
                moveDir = new Vector3(0, 0, 0);
            }
        }

            rot += Input.GetAxis("Horizontal") * rotSpeed * Time.deltaTime;
        transform.eulerAngles = new Vector3(0, rot, 0);
       
        moveDir.y -= gravity * Time.deltaTime;
        controller.Move(moveDir * Time.deltaTime);
    }

  
}
