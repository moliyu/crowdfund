import { useFactory } from "@/hooks/useFactory";
import clsx from "clsx";
import React, { useImperativeHandle, useRef, useState } from "react";

export interface ModalHandler {
  open: () => void;
}

type Props = {
  ref?: React.Ref<ModalHandler>;
  handleOk?: () => void;
};

export function CreateModal({ ref, handleOk }: Props) {
  const [show, setShow] = useState(false);
  const [name, setName] = useState("");
  const [goal, setGoal] = useState("");
  const [duration, setDuration] = useState("");
  const { createCrowdFunding } = useFactory();
  const modalRef = useRef<HTMLDialogElement>(null);
  const [loading, setLoading] = useState(false);

  async function handleCreate() {
    if (!name) {
      console.log("请输入名称");
      return;
    }
    if (!goal) {
      console.log("请输入目标");
      return;
    }

    if (!duration) {
      console.log("请输入持续时间");
      return;
    }
    setLoading(true);
    await createCrowdFunding({
      name,
      goal,
      durationIndayjs: BigInt(duration),
    });
    setLoading(false);
    setShow(false);
    handleOk?.();
  }

  useImperativeHandle(
    ref,
    () => {
      return {
        open() {
          setShow(true);
        },
      };
    },
    [],
  );

  return (
    <dialog className={clsx("modal", { "modal-open": show })} ref={modalRef}>
      <div className="modal-box">
        <form method="dialog">
          <button
            className="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
            onClick={() => {
              setShow(false);
            }}
          >
            ✕
          </button>
        </form>
        <h3 className="font-bold text-lg">新建项目</h3>
        <form action="" className="space-y-4">
          <fieldset>
            <legend>项目名称</legend>
            <input
              type="text"
              className="input"
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
          </fieldset>

          <fieldset>
            <legend>目标金额ETH</legend>
            <input
              type="number"
              className="input"
              value={goal}
              onChange={(e) => setGoal(e.target.value)}
              step={0.01}
              min={0}
            />
          </fieldset>

          <fieldset>
            <legend>持续时间</legend>
            <input
              className="input"
              type="value"
              step={1}
              min={1}
              value={duration}
              onChange={(e) => setDuration(e.target.value)}
            />
          </fieldset>

          <button
            className="btn btn-primary"
            disabled={loading}
            type="button"
            onClick={(e) => {
              handleCreate();
            }}
          >
            {loading && <span className="loading loading-spinner"></span>}
            确认
          </button>
        </form>
      </div>
    </dialog>
  );
}
